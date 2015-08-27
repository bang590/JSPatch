//  JPEngine.m
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPEngine.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIApplication.h>

@interface JPBoxing : NSObject
@property (nonatomic) id obj;
@property (nonatomic) void *pointer;
@property (nonatomic) Class cls;
@property (nonatomic, weak) id weakObj;
- (id)unbox;
- (void *)unboxPointer;
- (Class)unboxClass;
@end

@implementation JPBoxing

#define JPBOXING_GEN(_name, _prop, _type) \
+ (instancetype)_name:(_type)obj  \
{   \
    JPBoxing *boxing = [[JPBoxing alloc] init]; \
    boxing._prop = obj;   \
    return boxing;  \
}

JPBOXING_GEN(boxObj, obj, id)
JPBOXING_GEN(boxPointer, pointer, void *)
JPBOXING_GEN(boxClass, cls, Class)
JPBOXING_GEN(boxWeakObj, weakObj, id)

- (id)unbox
{
    if (self.obj) return self.obj;
    if (self.weakObj) return self.weakObj;
    return self;
}
- (void *)unboxPointer
{
    return self.pointer;
}
- (Class)unboxClass
{
    return self.cls;
}
@end



@implementation JPEngine

static JSContext *_context;
static NSString *_regexStr = @"\\.\\s*(\\w+)\\s*\\(";
static NSString *_replaceStr = @".__c(\"$1\")(";
static NSRegularExpression* _regex;
static NSObject *_nullObj;
static NSObject *_nilObj;
static NSMutableDictionary *registeredStruct;

#pragma mark - APIS

+ (void)startEngine
{
    if (![JSContext class] || _context) {
        return;
    }
    
    JSContext *context = [[JSContext alloc] init];
    
    context[@"_OC_defineClass"] = ^(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods) {
        return defineClass(classDeclaration, instanceMethods, classMethods);
    };
    
    context[@"_OC_callI"] = ^id(NSString *className, JSValue *obj, NSString *selectorName, JSValue *arguments, BOOL isSuper) {
        return callSelector(className, selectorName, arguments, obj, isSuper);
    };
    context[@"_OC_callC"] = ^id(NSString *className, NSString *selectorName, JSValue *arguments) {
        return callSelector(className, selectorName, arguments, nil, NO);
    };
    context[@"_OC_formatJSToOC"] = ^id(JSValue *obj) {
        return formatJSToOC(obj);
    };
    
    context[@"_OC_formatOCToJS"] = ^id(JSValue *obj) {
        return formatOCToJS([obj toObject]);
    };
    
    context[@"__weak"] = ^id(JSValue *jsval) {
        id obj = formatJSToOC(jsval);
        return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[formatOCToJS([JPBoxing boxWeakObj:obj])]];
    };

    context[@"__strong"] = ^id(JSValue *jsval) {
        id obj = formatJSToOC(jsval);
        return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[formatOCToJS(obj)]];
    };

    __weak JSContext *weakCtx = context;
    context[@"dispatch_after"] = ^(double time, JSValue *func) {
        JSValue *currSelf = weakCtx[@"self"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            JSValue *prevSelf = weakCtx[@"self"];
            weakCtx[@"self"] = currSelf;
            [func callWithArguments:nil];
            weakCtx[@"self"] = prevSelf;
        });
    };
    
    context[@"dispatch_async_main"] = ^(JSValue *func) {
        JSValue *currSelf = weakCtx[@"self"];
        dispatch_async(dispatch_get_main_queue(), ^{
            JSValue *prevSelf = weakCtx[@"self"];
            weakCtx[@"self"] = currSelf;
            [func callWithArguments:nil];
            weakCtx[@"self"] = prevSelf;
        });
    };
    
    context[@"dispatch_sync_main"] = ^(JSValue *func) {
        if ([NSThread currentThread].isMainThread) {
            [func callWithArguments:nil];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [func callWithArguments:nil];
            });
        }
    };
    
    context[@"dispatch_async_global_queue"] = ^(JSValue *func) {
        JSValue *currSelf = weakCtx[@"self"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            JSValue *prevSelf = weakCtx[@"self"];
            weakCtx[@"self"] = currSelf;
            [func callWithArguments:nil];
            weakCtx[@"self"] = prevSelf;
        });
    };
    
    context[@"releaseTmpObj"] = ^void(JSValue *jsVal) {
        if ([[jsVal toObject] isKindOfClass:[NSDictionary class]]) {
            void *pointer =  [(JPBoxing *)([jsVal toObject][@"__obj"]) unboxPointer];
            id obj = *((__unsafe_unretained id *)pointer);
            @synchronized(_TMPMemoryPool) {
                [_TMPMemoryPool removeObjectForKey:[NSNumber numberWithInteger:[obj hash]]];
            }
        }
    };

    context[@"_OC_log"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSLog(@"JSPatch.log: %@", formatJSToOC(jsVal));
        }
    };
    
    context[@"_OC_catch"] = ^(JSValue *msg, JSValue *stack) {
        NSAssert(NO, @"js exception, \nmsg: %@, \nstack: \n %@", [msg toObject], [stack toObject]);
    };
    
    context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        NSAssert(NO, @"js exception: %@", exception);
    };
    
    
    _nullObj = [[NSObject alloc] init];
    _nilObj = [[NSObject alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    _JSMethodSignatureLock = [[NSLock alloc]init];
    context[@"_OC_null"] = formatOCToJS(_nullObj);
    
    _context = context;
    registeredStruct = [[NSMutableDictionary alloc] init];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"JSPatch" ofType:@"js"];
    NSAssert(path, @"can't find JSPatch.js");
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    
    if ([_context respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
        [_context evaluateScript:jsCore withSourceURL:[NSURL URLWithString:@"JSPatch.js"]];
    } else {
        [_context evaluateScript:jsCore];
    }
}

+ (JSValue *)evaluateScript:(NSString *)script
{
    return [self evaluateScript:script withSourceURL:[NSURL URLWithString:@"main.js"]];
}

+ (JSValue *)evaluateScriptWithPath:(NSString *)filePath
{
    NSArray *components = [filePath componentsSeparatedByString:@"/"];
    NSString *fileName = [components lastObject];
    NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [self evaluateScript:script withSourceURL:[NSURL URLWithString:fileName]];
}

+ (JSValue *)evaluateScript:(NSString *)script withSourceURL:(NSURL *)resourceURL
{
    if (!script || ![JSContext class]) {
        NSAssert(script, @"script is nil");
        return nil;
    }
    
    if (!_regex) {
        _regex = [NSRegularExpression regularExpressionWithPattern:_regexStr options:0 error:nil];
    }
    NSString *formatedScript = [NSString stringWithFormat:@"try{%@}catch(e){_OC_catch(e.message, e.stack)}", [_regex stringByReplacingMatchesInString:script options:0 range:NSMakeRange(0, script.length) withTemplate:_replaceStr]];
    @try {
        if ([_context respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
            return [_context evaluateScript:formatedScript withSourceURL:resourceURL];
        } else {
            return [_context evaluateScript:formatedScript];
        }
    }
    @catch (NSException *exception) {
        NSAssert(NO, @"%@", exception);
    }
    return nil;
}

+ (JSContext *)context
{
    return _context;
}

+ (void)addExtensions:(NSArray *)extensions
{
    if (![JSContext class]) {
        return;
    }
    NSAssert(_context, @"please call [JPEngine startEngine]");
    @synchronized (_context) {
        for (NSString *className in extensions) {
            Class extCls = NSClassFromString(className);
            [extCls main:_context];
        }
    }
}

+ (void)defineStruct:(NSDictionary *)defineDict
{
    @synchronized (_context) {
        [registeredStruct setObject:defineDict forKey:defineDict[@"name"]];
    }
}

+ (NSMutableDictionary *)registeredStruct
{
    return registeredStruct;
}

+ (void)handleMemoryWarning {
    @synchronized(_JSMethodSignatureCache) {
        _JSMethodSignatureCache = nil;
    }
}

#pragma mark - Implements

static NSMutableDictionary *_JSOverideMethods;
static NSMutableDictionary *_TMPMemoryPool;
static NSRegularExpression *countArgRegex;
static NSMutableDictionary *_propKeys;
static NSMutableDictionary *_JSMethodSignatureCache;
static NSLock              *_JSMethodSignatureLock;

static const void *propKey(NSString *propName) {
    if (!_propKeys) _propKeys = [[NSMutableDictionary alloc] init];
    id key = _propKeys[propName];
    if (!key) {
        key = [propName copy];
        [_propKeys setObject:key forKey:propName];
    }
    return (__bridge const void *)(key);
}
static id getPropIMP(id slf, SEL selector, NSString *propName) {
    return objc_getAssociatedObject(slf, propKey(propName));
}
static void setPropIMP(id slf, SEL selector, id val, NSString *propName) {
    objc_setAssociatedObject(slf, propKey(propName), val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char *methodTypesInProtocol(NSString *protocolName, NSString *selectorName, BOOL isInstanceMethod, BOOL isRequired)
{
    Protocol *protocol = objc_getProtocol([trim(protocolName) cStringUsingEncoding:NSUTF8StringEncoding]);
    unsigned int selCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, isRequired, isInstanceMethod, &selCount);
    for (int i = 0; i < selCount; i ++) {
        if ([selectorName isEqualToString:NSStringFromSelector(methods[i].name)]) {
            return methods[i].types;
        }
    }
    return NULL;
}

static NSDictionary *defineClass(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods)
{
    NSString *className;
    NSString *superClassName;
    NSString *protocolNames;
    
    NSScanner *scanner = [NSScanner scannerWithString:classDeclaration];
    [scanner scanUpToString:@":" intoString:&className];
    if (!scanner.isAtEnd) {
        scanner.scanLocation = scanner.scanLocation + 1;
        [scanner scanUpToString:@"<" intoString:&superClassName];
        if (!scanner.isAtEnd) {
            scanner.scanLocation = scanner.scanLocation + 1;
            [scanner scanUpToString:@">" intoString:&protocolNames];
        }
    }
    NSArray *protocols = [protocolNames componentsSeparatedByString:@","];
    if (!superClassName) superClassName = @"NSObject";
    className = trim(className);
    superClassName = trim(superClassName);
    
    Class cls = NSClassFromString(className);
    if (!cls) {
        Class superCls = NSClassFromString(superClassName);
        cls = objc_allocateClassPair(superCls, className.UTF8String, 0);
        objc_registerClassPair(cls);
    }
    
    for (int i = 0; i < 2; i ++) {
        BOOL isInstance = i == 0;
        JSValue *jsMethods = isInstance ? instanceMethods: classMethods;
        
        Class currCls = isInstance ? cls: objc_getMetaClass(className.UTF8String);
        NSDictionary *methodDict = [jsMethods toDictionary];
        for (NSString *jsMethodName in methodDict.allKeys) {
            JSValue *jsMethodArr = [jsMethods valueForProperty:jsMethodName];
            int numberOfArg = [jsMethodArr[0] toInt32];
            NSString *tmpJSMethodName = [jsMethodName stringByReplacingOccurrencesOfString:@"__" withString:@"-"];
            NSString *selectorName = [tmpJSMethodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
            selectorName = [selectorName stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
            
            if (!countArgRegex) {
                countArgRegex = [NSRegularExpression regularExpressionWithPattern:@":" options:NSRegularExpressionCaseInsensitive error:nil];
            }
            NSUInteger numberOfMatches = [countArgRegex numberOfMatchesInString:selectorName options:0 range:NSMakeRange(0, [selectorName length])];
            if (numberOfMatches < numberOfArg) {
                selectorName = [selectorName stringByAppendingString:@":"];
            }
            
            JSValue *jsMethod = jsMethodArr[1];
            if (class_respondsToSelector(currCls, NSSelectorFromString(selectorName))) {
                overrideMethod(currCls, selectorName, jsMethod, !isInstance, NULL);
            } else {
                BOOL overrided = NO;
                for (NSString *protocolName in protocols) {
                    char *types = methodTypesInProtocol(protocolName, selectorName, isInstance, YES);
                    if (!types) types = methodTypesInProtocol(protocolName, selectorName, isInstance, NO);
                    if (types) {
                        overrideMethod(currCls, selectorName, jsMethod, !isInstance, types);
                        overrided = YES;
                        break;
                    }
                }
                if (!overrided) {
                    NSMutableString *typeDescStr = [@"@@:" mutableCopy];
                    for (int i = 0; i < numberOfArg; i ++) {
                        [typeDescStr appendString:@"@"];
                    }
                    overrideMethod(currCls, selectorName, jsMethod, !isInstance, [typeDescStr cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_addMethod(cls, @selector(getProp:), (IMP)getPropIMP, "@@:@");
    class_addMethod(cls, @selector(setProp:forKey:), (IMP)setPropIMP, "v@:@@");
#pragma clang diagnostic pop

    return @{@"cls": className};
}

static JSValue* getJSFunctionInObjectHierachy(id slf, NSString *selectorName)
{
    Class cls = object_getClass(slf);
    JSValue *func = _JSOverideMethods[cls][selectorName];
    while (!func) {
        cls = class_getSuperclass(cls);
        if (!cls) {
            NSCAssert(NO, @"warning can not find selector %@", selectorName);
            return nil;
        }
        func = _JSOverideMethods[cls][selectorName];
    }
    return func;
}

#pragma clang diagnostic pop

static void JPForwardInvocation(id slf, SEL selector, NSInvocation *invocation)
{
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSInteger numberOfArguments = [methodSignature numberOfArguments];
    
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    NSString *JPSelectorName = [NSString stringWithFormat:@"_JP%@", selectorName];
    SEL JPSelector = NSSelectorFromString(JPSelectorName);
    
    if (!class_respondsToSelector(object_getClass(slf), JPSelector)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL origForwardSelector = @selector(ORIGforwardInvocation:);
        NSMethodSignature *methodSignature = [slf methodSignatureForSelector:origForwardSelector];
        NSInvocation *forwardInv= [NSInvocation invocationWithMethodSignature:methodSignature];
        [forwardInv setTarget:slf];
        [forwardInv setSelector:origForwardSelector];
        [forwardInv setArgument:&invocation atIndex:2];
        [forwardInv invoke];
        return;
#pragma clang diagnostic pop
    }
    
    NSMutableArray *argList = [[NSMutableArray alloc] init];
    [argList addObject:slf];
    
    for (NSUInteger i = 2; i < numberOfArguments; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        switch(argumentType[0]) {
        
            #define JP_FWD_ARG_CASE(_typeChar, _type) \
            case _typeChar: {   \
                _type arg;  \
                [invocation getArgument:&arg atIndex:i];    \
                [argList addObject:@(arg)]; \
                break;  \
            }
            JP_FWD_ARG_CASE('c', char)
            JP_FWD_ARG_CASE('C', unsigned char)
            JP_FWD_ARG_CASE('s', short)
            JP_FWD_ARG_CASE('S', unsigned short)
            JP_FWD_ARG_CASE('i', int)
            JP_FWD_ARG_CASE('I', unsigned int)
            JP_FWD_ARG_CASE('l', long)
            JP_FWD_ARG_CASE('L', unsigned long)
            JP_FWD_ARG_CASE('q', long long)
            JP_FWD_ARG_CASE('Q', unsigned long long)
            JP_FWD_ARG_CASE('f', float)
            JP_FWD_ARG_CASE('d', double)
            JP_FWD_ARG_CASE('B', BOOL)
            case '@': {
                __unsafe_unretained id arg;
                [invocation getArgument:&arg atIndex:i];
                static const char *blockType = @encode(typeof(^{}));
                if (!strcmp(argumentType, blockType)) {
                    [argList addObject:(arg ? [arg copy]: _nilObj)];
                } else {
                    [argList addObject:(arg ? arg: _nilObj)];
                }
                break;
            }
            case '{': {
                NSString *typeString = extractStructName([NSString stringWithUTF8String:argumentType]);
                #define JP_FWD_ARG_STRUCT(_type, _transFunc) \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    _type arg; \
                    [invocation getArgument:&arg atIndex:i];    \
                    [argList addObject:[JSValue _transFunc:arg inContext:[JSContext currentContext]]];  \
                    break; \
                }
                JP_FWD_ARG_STRUCT(CGRect, valueWithRect)
                JP_FWD_ARG_STRUCT(CGPoint, valueWithPoint)
                JP_FWD_ARG_STRUCT(CGSize, valueWithSize)
                JP_FWD_ARG_STRUCT(NSRange, valueWithRange)
                
                @synchronized (_context) {
                    NSDictionary *structDefine = registeredStruct[typeString];
                    if (structDefine) {
                        size_t size = sizeOfStructTypes(structDefine[@"types"]);
                        if (size) {
                            void *ret = malloc(size);
                            [invocation getArgument:ret atIndex:i];
                            NSDictionary *dict = getDictOfStruct(ret, structDefine);
                            [argList addObject:dict];
                            free(ret);
                            break;
                        }
                    }
                }
                
                break;
            }
            case ':': {
                SEL selector;
                [invocation getArgument:&selector atIndex:i];
                NSString *selectorName = NSStringFromSelector(selector);
                [argList addObject:(selectorName ? selectorName: _nilObj)];
                break;
            }
            case '^':
            case '*': {
                void *arg;
                [invocation getArgument:&arg atIndex:i];
                [argList addObject:[JPBoxing boxPointer:arg]];
                break;
            }
            case '#': {
                Class arg;
                [invocation getArgument:&arg atIndex:i];
                [argList addObject:[JPBoxing boxClass:arg]];
                break;
            }
            default: {
                NSLog(@"error type %s", argumentType);
                break;
            }
        }
    }
    
    NSArray *params = _formatOCToJSList(argList);
    const char *returnType = [methodSignature methodReturnType];

    switch (returnType[0]) {
        #define JP_FWD_RET_CALL_JS \
            JSValue *fun = getJSFunctionInObjectHierachy(slf, JPSelectorName); \
            JSValue *jsval; \
            @synchronized(_context) {   \
                jsval = [fun callWithArguments:params];\
            }

        #define JP_FWD_RET_CASE_RET(_typeChar, _type, _retCode)   \
            case _typeChar : { \
                JP_FWD_RET_CALL_JS \
                _retCode \
                [invocation setReturnValue:&ret];\
                break;  \
            }

        #define JP_FWD_RET_CASE(_typeChar, _type, _typeSelector)   \
            JP_FWD_RET_CASE_RET(_typeChar, _type, _type ret = [[jsval toObject] _typeSelector];)   \

        #define JP_FWD_RET_CODE_ID \
            id ret = formatJSToOC(jsval); \
            if (ret == _nilObj ||   \
                ([ret isKindOfClass:[NSNumber class]] && strcmp([ret objCType], "c") == 0 && ![ret boolValue])) ret = nil;  \

        #define JP_FWD_RET_CODE_POINTER    \
            void *ret; \
            id obj = formatJSToOC(jsval); \
            if ([obj isKindOfClass:[JPBoxing class]]) { \
                ret = [((JPBoxing *)obj) unboxPointer]; \
            }

        #define JP_FWD_RET_CODE_CLASS    \
            Class ret;   \
            id obj = formatJSToOC(jsval); \
            if ([obj isKindOfClass:[JPBoxing class]]) { \
                ret = [((JPBoxing *)obj) unboxClass]; \
            }

        #define JP_FWD_RET_CODE_SEL    \
            SEL ret;   \
            id obj = formatJSToOC(jsval); \
            if ([obj isKindOfClass:[NSString class]]) { \
                ret = NSSelectorFromString(obj); \
            }

        JP_FWD_RET_CASE_RET('@', id, JP_FWD_RET_CODE_ID)

        JP_FWD_RET_CASE_RET('^', void*, JP_FWD_RET_CODE_POINTER)
        JP_FWD_RET_CASE_RET('*', void*, JP_FWD_RET_CODE_POINTER)
        JP_FWD_RET_CASE_RET('#', Class, JP_FWD_RET_CODE_CLASS)
        JP_FWD_RET_CASE_RET(':', SEL, JP_FWD_RET_CODE_SEL)

        JP_FWD_RET_CASE('c', char, charValue)
        JP_FWD_RET_CASE('C', unsigned char, unsignedCharValue)
        JP_FWD_RET_CASE('s', short, shortValue)
        JP_FWD_RET_CASE('S', unsigned short, unsignedShortValue)
        JP_FWD_RET_CASE('i', int, intValue)
        JP_FWD_RET_CASE('I', unsigned int, unsignedIntValue)
        JP_FWD_RET_CASE('l', long, longValue)
        JP_FWD_RET_CASE('L', unsigned long, unsignedLongValue)
        JP_FWD_RET_CASE('q', long long, longLongValue)
        JP_FWD_RET_CASE('Q', unsigned long long, unsignedLongLongValue)
        JP_FWD_RET_CASE('f', float, floatValue)
        JP_FWD_RET_CASE('d', double, doubleValue)
        JP_FWD_RET_CASE('B', BOOL, boolValue)

        case 'v': {
            JP_FWD_RET_CALL_JS
            break;
        }
        
        case '{': {
            NSString *typeString = extractStructName([NSString stringWithUTF8String:returnType]);
            #define JP_FWD_RET_STRUCT(_type, _funcSuffix) \
            if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                JP_FWD_RET_CALL_JS \
                _type ret = [jsval _funcSuffix]; \
                [invocation setReturnValue:&ret];\
                break;  \
            }
            JP_FWD_RET_STRUCT(CGRect, toRect)
            JP_FWD_RET_STRUCT(CGPoint, toPoint)
            JP_FWD_RET_STRUCT(CGSize, toSize)
            JP_FWD_RET_STRUCT(NSRange, toRange)
            break;
        }
        default: {
            break;
        }
    }
}

static void _initJPOverideMethods(Class cls) {
    if (!_JSOverideMethods) {
        _JSOverideMethods = [[NSMutableDictionary alloc] init];
    }
    if (!_JSOverideMethods[cls]) {
        _JSOverideMethods[(id<NSCopying>)cls] = [[NSMutableDictionary alloc] init];
    }
}

static void overrideMethod(Class cls, NSString *selectorName, JSValue *function, BOOL isClassMethod, const char *typeDescription)
{
    SEL selector = NSSelectorFromString(selectorName);
    
    NSMethodSignature *methodSignature;
    
    if (typeDescription) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:typeDescription];
    } else {
        methodSignature = [cls instanceMethodSignatureForSelector:selector];
        Method method = class_getInstanceMethod(cls, selector);
        typeDescription = (char *)method_getTypeEncoding(method);
    }
    
    IMP originalImp = class_respondsToSelector(cls, selector) ? class_getMethodImplementation(cls, selector) : NULL;
    
    IMP msgForwardIMP = _objc_msgForward;
    #if !defined(__arm64__)
        if (typeDescription[0] == '{') {
            //In some cases that returns struct, we should use the '_stret' API:
            //http://sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html
            //NSMethodSignature knows the detail but has no API to return, we can only get the info from debugDescription.
            if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
                msgForwardIMP = (IMP)_objc_msgForward_stret;
            }
        }
    #endif

    class_replaceMethod(cls, selector, msgForwardIMP, typeDescription);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (class_getMethodImplementation(cls, @selector(forwardInvocation:)) != (IMP)JPForwardInvocation) {
        IMP originalForwardImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)JPForwardInvocation, "v@:@");
        class_addMethod(cls, @selector(ORIGforwardInvocation:), originalForwardImp, "v@:@");
    }
#pragma clang diagnostic pop

    if (class_respondsToSelector(cls, selector)) {
        NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", selectorName];
        SEL originalSelector = NSSelectorFromString(originalSelectorName);
        if(!class_respondsToSelector(cls, originalSelector)) {
            class_addMethod(cls, originalSelector, originalImp, typeDescription);
        }
    }
    
    NSString *JPSelectorName = [NSString stringWithFormat:@"_JP%@", selectorName];
    SEL JPSelector = NSSelectorFromString(JPSelectorName);

    _initJPOverideMethods(cls);
    _JSOverideMethods[cls][JPSelectorName] = function;
    
    class_addMethod(cls, JPSelector, msgForwardIMP, typeDescription);
}

#pragma mark -

static id callSelector(NSString *className, NSString *selectorName, JSValue *arguments, JSValue *instance, BOOL isSuper)
{
    if (instance) {
        instance = formatJSToOC(instance);
        if (!instance || instance == _nilObj) return @{@"__isNil": @(YES)};
    }
    id argumentsObj = formatJSToOC(arguments);
    
    if (instance && [selectorName isEqualToString:@"toJS"]) {
        if ([instance isKindOfClass:[NSString class]] || [instance isKindOfClass:[NSDictionary class]] || [instance isKindOfClass:[NSArray class]]) {
            return _unboxOCObjectToJS(instance);
        }
    }

    Class cls = instance ? [instance class] : NSClassFromString(className);
    SEL selector = NSSelectorFromString(selectorName);
    
    if (isSuper) {
        NSString *superSelectorName = [NSString stringWithFormat:@"SUPER_%@", selectorName];
        SEL superSelector = NSSelectorFromString(superSelectorName);
        
        Class superCls = [cls superclass];
        Method superMethod = class_getInstanceMethod(superCls, selector);
        IMP superIMP = method_getImplementation(superMethod);
        
        class_addMethod(cls, superSelector, superIMP, method_getTypeEncoding(superMethod));
        
        NSString *JPSelectorName = [NSString stringWithFormat:@"_JP%@", selectorName];
        JSValue *overideFunction = _JSOverideMethods[superCls][JPSelectorName];
        if (overideFunction) {
            overrideMethod(cls, superSelectorName, overideFunction, NO, NULL);
        }
        
        selector = superSelector;
    }
    
    
    NSMutableArray *_markArray;
    
    NSInvocation *invocation;
    NSMethodSignature *methodSignature;
    if (!_JSMethodSignatureCache) {
        _JSMethodSignatureCache = [[NSMutableDictionary alloc]init];
    }
    if (instance) {
        [_JSMethodSignatureLock lock];
        if (!_JSMethodSignatureCache[className]) {
            _JSMethodSignatureCache[className] = [[NSMutableDictionary alloc]init];
        }
        methodSignature = _JSMethodSignatureCache[className][selectorName];
        if (!methodSignature) {
            methodSignature = [cls instanceMethodSignatureForSelector:selector];
            _JSMethodSignatureCache[className][selectorName] = methodSignature;
        }
        [_JSMethodSignatureLock unlock];
        NSCAssert(methodSignature, @"unrecognized selector %@ for instance %@", selectorName, instance);
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:instance];
    } else {
        methodSignature = [cls methodSignatureForSelector:selector];
        NSCAssert(methodSignature, @"unrecognized selector %@ for class %@", selectorName, className);
        invocation= [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:cls];
    }
    [invocation setSelector:selector];
    
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    for (NSUInteger i = 2; i < numberOfArguments; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        id valObj = argumentsObj[i-2];
        switch (argumentType[0]) {
                
                #define JP_CALL_ARG_CASE(_typeString, _type, _selector) \
                case _typeString: {                              \
                    _type value = [valObj _selector];                     \
                    [invocation setArgument:&value atIndex:i];\
                    break; \
                }
                
                JP_CALL_ARG_CASE('c', char, charValue)
                JP_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
                JP_CALL_ARG_CASE('s', short, shortValue)
                JP_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
                JP_CALL_ARG_CASE('i', int, intValue)
                JP_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
                JP_CALL_ARG_CASE('l', long, longValue)
                JP_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
                JP_CALL_ARG_CASE('q', long long, longLongValue)
                JP_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
                JP_CALL_ARG_CASE('f', float, floatValue)
                JP_CALL_ARG_CASE('d', double, doubleValue)
                JP_CALL_ARG_CASE('B', BOOL, boolValue)
                
            case ':': {
                SEL value = nil;
                if (valObj != _nilObj) {
                    value = NSSelectorFromString(valObj);
                }
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '{': {
                NSString *typeString = extractStructName([NSString stringWithUTF8String:argumentType]);
                JSValue *val = arguments[i-2];
                #define JP_CALL_ARG_STRUCT(_type, _methodName) \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    _type value = [val _methodName];  \
                    [invocation setArgument:&value atIndex:i];  \
                    break; \
                }
                JP_CALL_ARG_STRUCT(CGRect, toRect)
                JP_CALL_ARG_STRUCT(CGPoint, toPoint)
                JP_CALL_ARG_STRUCT(CGSize, toSize)
                JP_CALL_ARG_STRUCT(NSRange, toRange)
                @synchronized (_context) {
                    NSDictionary *structDefine = registeredStruct[typeString];
                    if (structDefine) {
                        size_t size = sizeOfStructTypes(structDefine[@"types"]);
                        void *ret = malloc(size);
                        getStructDataWithDict(ret, valObj, structDefine);
                        [invocation setArgument:ret atIndex:i];
                        free(ret);
                        break;
                    }
                }
                
                break;
            }
            case '*':
            case '^': {
                if ([valObj isKindOfClass:[JPBoxing class]]) {
                    void *value = [((JPBoxing *)valObj) unboxPointer];
                    
                    if (argumentType[1] == '@') {
                        if (!_TMPMemoryPool) {
                            _TMPMemoryPool = [[NSMutableDictionary alloc] init];
                        }
                        if (!_markArray) {
                            _markArray = [[NSMutableArray alloc] init];
                        }
                        memset(value, 0, sizeof(id));
                        [_markArray addObject:valObj];
                    }
                    
                    [invocation setArgument:&value atIndex:i];
                    break;
                }
            }
            case '#': {
                if ([valObj isKindOfClass:[JPBoxing class]]) {
                    Class value = [((JPBoxing *)valObj) unboxClass];
                    [invocation setArgument:&value atIndex:i];
                    break;
                }
            }
            default: {
                if (valObj == _nullObj) {
                    valObj = [NSNull null];
                    [invocation setArgument:&valObj atIndex:i];
                    break;
                }
                if (valObj == _nilObj ||
                    ([valObj isKindOfClass:[NSNumber class]] && strcmp([valObj objCType], "c") == 0 && ![valObj boolValue])) {
                    valObj = nil;
                    [invocation setArgument:&valObj atIndex:i];
                    break;
                }
                static const char *blockType = @encode(typeof(^{}));
                if (!strcmp(argumentType, blockType)) {
                    __autoreleasing id cb = genCallbackBlock(arguments[i-2]);
                    [invocation setArgument:&cb atIndex:i];
                } else {
                    if ([valObj isMemberOfClass:[JPBoxing class]]) {
                        id obj = (__bridge id)[valObj unboxPointer];
                        [invocation setArgument:&obj atIndex:i];
                    }else{
                        [invocation setArgument:&valObj atIndex:i];
                    }
                }
            }
        }
    }
    
    [invocation invoke];
    if ([_markArray count] > 0) {
        for (JPBoxing *box in _markArray) {
            void *pointer = [box unboxPointer];
            id obj = *((__unsafe_unretained id *)pointer);
            if (obj) {
                @synchronized(_TMPMemoryPool) {
                    [_TMPMemoryPool setObject:obj forKey:[NSNumber numberWithInteger:[obj hash]]];
                }
            }
        }
    }
    const char *returnType = [methodSignature methodReturnType];
    id returnValue;
    if (strncmp(returnType, "v", 1) != 0) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];
            
            //For performance, ignore the other methods prefix with alloc/new/copy/mutableCopy
            if ([selectorName isEqualToString:@"alloc"] || [selectorName isEqualToString:@"new"] ||
                [selectorName isEqualToString:@"copy"] || [selectorName isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            } else {
                returnValue = (__bridge id)result;
            }
            return formatOCToJS(returnValue);
            
        } else {
            switch (returnType[0]) {
                    
                #define JP_CALL_RET_CASE(_typeString, _type) \
                case _typeString: {                              \
                    _type tempResultSet; \
                    [invocation getReturnValue:&tempResultSet];\
                    returnValue = @(tempResultSet); \
                    break; \
                }
                    
                JP_CALL_RET_CASE('c', char)
                JP_CALL_RET_CASE('C', unsigned char)
                JP_CALL_RET_CASE('s', short)
                JP_CALL_RET_CASE('S', unsigned short)
                JP_CALL_RET_CASE('i', int)
                JP_CALL_RET_CASE('I', unsigned int)
                JP_CALL_RET_CASE('l', long)
                JP_CALL_RET_CASE('L', unsigned long)
                JP_CALL_RET_CASE('q', long long)
                JP_CALL_RET_CASE('Q', unsigned long long)
                JP_CALL_RET_CASE('f', float)
                JP_CALL_RET_CASE('d', double)
                JP_CALL_RET_CASE('B', BOOL)

                case '{': {
                    NSString *typeString = extractStructName([NSString stringWithUTF8String:returnType]);
                    #define JP_CALL_RET_STRUCT(_type, _methodName) \
                    if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                        _type result;   \
                        [invocation getReturnValue:&result];    \
                        return [JSValue _methodName:result inContext:[JSContext currentContext]];    \
                    }
                    JP_CALL_RET_STRUCT(CGRect, valueWithRect)
                    JP_CALL_RET_STRUCT(CGPoint, valueWithPoint)
                    JP_CALL_RET_STRUCT(CGSize, valueWithSize)
                    JP_CALL_RET_STRUCT(NSRange, valueWithRange)
                    @synchronized (_context) {
                        
                        NSDictionary *structDefine = registeredStruct[typeString];
                        if (structDefine) {
                            size_t size = sizeOfStructTypes(structDefine[@"types"]);
                            void *ret = malloc(size);
                            [invocation getReturnValue:ret];
                            NSDictionary *dict = getDictOfStruct(ret, structDefine);
                            free(ret);
                            return dict;
                        }
                    }
                    break;
                }
                case '*':
                case '^': {
                    void *result;
                    [invocation getReturnValue:&result];
                    returnValue = formatOCToJS([JPBoxing boxPointer:result]);
                    break;
                }
                case '#': {
                    Class result;
                    [invocation getReturnValue:&result];
                    returnValue = formatOCToJS([JPBoxing boxClass:result]);
                    break;
                }
            }
            return returnValue;
        }
    }
    return nil;
}

#pragma mark -

static id genCallbackBlock(JSValue *jsVal)
{
#define BLK_DEFINE_1 cb = ^id(void *p0) {
#define BLK_DEFINE_2 cb = ^id(void *p0, void *p1) {
#define BLK_DEFINE_3 cb = ^id(void *p0, void *p1, void *p2) {
#define BLK_DEFINE_4 cb = ^id(void *p0, void *p1, void *p2, void *p3) {

#define BLK_ADD_OBJ(_paramName) [list addObject:formatOCToJS((__bridge id)_paramName)];
#define BLK_ADD_INT(_paramName) [list addObject:formatOCToJS([NSNumber numberWithLongLong:(long long)_paramName])];

#define BLK_TRAITS_ARG(_idx, _paramName) \
    if (blockTypeIsObject(trim(argTypes[_idx]))) {  \
        BLK_ADD_OBJ(_paramName) \
    } else {  \
        BLK_ADD_INT(_paramName) \
    }   \

#define BLK_END \
    JSValue *ret = [jsVal[@"cb"] callWithArguments:list];    \
    return formatJSToOC(ret); \
};

    NSArray *argTypes = [[jsVal[@"args"] toString] componentsSeparatedByString:@","];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSInteger count = argTypes.count;
    id cb;
    if (count == 1) {
        BLK_DEFINE_1
        BLK_TRAITS_ARG(0, p0)
        BLK_END
    }
    if (count == 2) {
        BLK_DEFINE_2
        BLK_TRAITS_ARG(0, p0)
        BLK_TRAITS_ARG(1, p1)
        BLK_END
    }
    if (count == 3) {
        BLK_DEFINE_3
        BLK_TRAITS_ARG(0, p0)
        BLK_TRAITS_ARG(1, p1)
        BLK_TRAITS_ARG(2, p2)
        BLK_END
    }
    if (count == 4) {
        BLK_DEFINE_4
        BLK_TRAITS_ARG(0, p0)
        BLK_TRAITS_ARG(1, p1)
        BLK_TRAITS_ARG(2, p2)
        BLK_TRAITS_ARG(3, p3)
        BLK_END
    }
    return cb;
}

#pragma mark - Struct

static int sizeOfStructTypes(NSString *structTypes)
{
    const char *types = [structTypes cStringUsingEncoding:NSUTF8StringEncoding];
    int index = 0;
    int size = 0;
    while (types[index]) {
        switch (types[index]) {
            #define JP_STRUCT_SIZE_CASE(_typeChar, _type)   \
            case _typeChar: \
                size += sizeof(_type);  \
                break;
                
            JP_STRUCT_SIZE_CASE('c', char)
            JP_STRUCT_SIZE_CASE('C', unsigned char)
            JP_STRUCT_SIZE_CASE('s', short)
            JP_STRUCT_SIZE_CASE('S', unsigned short)
            JP_STRUCT_SIZE_CASE('i', int)
            JP_STRUCT_SIZE_CASE('I', unsigned int)
            JP_STRUCT_SIZE_CASE('l', long)
            JP_STRUCT_SIZE_CASE('L', unsigned long)
            JP_STRUCT_SIZE_CASE('q', long long)
            JP_STRUCT_SIZE_CASE('Q', unsigned long long)
            JP_STRUCT_SIZE_CASE('f', float)
            JP_STRUCT_SIZE_CASE('F', CGFloat)
            JP_STRUCT_SIZE_CASE('N', NSInteger)
            JP_STRUCT_SIZE_CASE('U', NSUInteger)
            JP_STRUCT_SIZE_CASE('d', double)
            JP_STRUCT_SIZE_CASE('B', BOOL)
            JP_STRUCT_SIZE_CASE('*', void *)
            JP_STRUCT_SIZE_CASE('^', void *)
            
            default:
                break;
        }
        index ++;
    }
    return size;
}

static void getStructDataWithDict(void *structData, NSDictionary *dict, NSDictionary *structDefine)
{
    NSArray *itemKeys = structDefine[@"keys"];
    const char *structTypes = [structDefine[@"types"] cStringUsingEncoding:NSUTF8StringEncoding];
    int position = 0;
    for (int i = 0; i < itemKeys.count; i ++) {
        switch(structTypes[i]) {
            #define JP_STRUCT_DATA_CASE(_typeStr, _type, _transMethod) \
            case _typeStr: { \
                int size = sizeof(_type);    \
                _type val = [dict[itemKeys[i]] _transMethod];   \
                memcpy(structData + position, &val, size);  \
                position += size;    \
                break;  \
            }
                
            JP_STRUCT_DATA_CASE('c', char, charValue)
            JP_STRUCT_DATA_CASE('C', unsigned char, unsignedCharValue)
            JP_STRUCT_DATA_CASE('s', short, shortValue)
            JP_STRUCT_DATA_CASE('S', unsigned short, unsignedShortValue)
            JP_STRUCT_DATA_CASE('i', int, intValue)
            JP_STRUCT_DATA_CASE('I', unsigned int, unsignedIntValue)
            JP_STRUCT_DATA_CASE('l', long, longValue)
            JP_STRUCT_DATA_CASE('L', unsigned long, unsignedLongValue)
            JP_STRUCT_DATA_CASE('q', long long, longLongValue)
            JP_STRUCT_DATA_CASE('Q', unsigned long long, unsignedLongLongValue)
            JP_STRUCT_DATA_CASE('f', float, floatValue)
            JP_STRUCT_DATA_CASE('d', double, doubleValue)
            JP_STRUCT_DATA_CASE('B', BOOL, boolValue)
            JP_STRUCT_DATA_CASE('N', NSInteger, integerValue)
            JP_STRUCT_DATA_CASE('U', NSUInteger, unsignedIntegerValue)
            
            case 'F': {
                int size = sizeof(CGFloat);
                CGFloat val;
                if (size == sizeof(double)) {
                    val = [dict[itemKeys[i]] doubleValue];
                } else {
                    val = [dict[itemKeys[i]] floatValue];
                }
                memcpy(structData + position, &val, size);
                position += size;
                break;
            }
            
            case '*':
            case '^': {
                int size = sizeof(void *);
                void *val = [(JPBoxing *)dict[itemKeys[i]] unboxPointer];
                memcpy(structData + position, &val, size);
                break;
            }
            
        }
    }
}

static NSDictionary *getDictOfStruct(void *structData, NSDictionary *structDefine)
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *itemKeys = structDefine[@"keys"];
    const char *structTypes = [structDefine[@"types"] cStringUsingEncoding:NSUTF8StringEncoding];
    int position = 0;
    
    for (int i = 0; i < itemKeys.count; i ++) {
        switch(structTypes[i]) {
            #define JP_STRUCT_DICT_CASE(_typeName, _type)   \
            case _typeName: { \
                size_t size = sizeof(_type); \
                _type *val = malloc(size);   \
                memcpy(val, structData + position, size);   \
                [dict setObject:@(*val) forKey:itemKeys[i]];    \
                position += size;   \
                break;  \
            }
            JP_STRUCT_DICT_CASE('c', char)
            JP_STRUCT_DICT_CASE('C', unsigned char)
            JP_STRUCT_DICT_CASE('s', short)
            JP_STRUCT_DICT_CASE('S', unsigned short)
            JP_STRUCT_DICT_CASE('i', int)
            JP_STRUCT_DICT_CASE('I', unsigned int)
            JP_STRUCT_DICT_CASE('l', long)
            JP_STRUCT_DICT_CASE('L', unsigned long)
            JP_STRUCT_DICT_CASE('q', long long)
            JP_STRUCT_DICT_CASE('Q', unsigned long long)
            JP_STRUCT_DICT_CASE('f', float)
            JP_STRUCT_DICT_CASE('F', CGFloat)
            JP_STRUCT_DICT_CASE('N', NSInteger)
            JP_STRUCT_DICT_CASE('U', NSUInteger)
            JP_STRUCT_DICT_CASE('d', double)
            JP_STRUCT_DICT_CASE('B', BOOL)
            
            case '*':
            case '^': {
                size_t size = sizeof(void *);
                void *val = malloc(size);
                memcpy(val, structData + position, size);
                [dict setObject:[JPBoxing boxPointer:val] forKey:itemKeys[i]];
                position += size;
                break;
            }
            
        }
    }
    return dict;
}

static NSString *extractStructName(NSString *typeEncodeString)
{
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    int firstValidIndex = 0;
    for (int i = 0; i< typeString.length; i++) {
        char c = [typeString characterAtIndex:i];
        if (c == '{' || c=='_') {
            firstValidIndex++;
        }else {
            break;
        }
    }
    return [typeString substringFromIndex:firstValidIndex];
}

#pragma mark - Utils

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static BOOL blockTypeIsObject(NSString *typeString)
{
    return [typeString rangeOfString:@"*"].location != NSNotFound || [typeString isEqualToString:@"id"];
}

#pragma mark - Object format

static id formatOCToJS(id obj)
{
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
        return _wrapObj([JPBoxing boxObj:obj]);
    }
    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:NSClassFromString(@"NSBlock")] || [obj isKindOfClass:[JSValue class]]) {
        return obj;
    }
    return _wrapObj(obj);
}

static id formatJSToOC(JSValue *jsval)
{
    id obj = [jsval toObject];
    if (!obj || [obj isKindOfClass:[NSNull class]]) return _nilObj;
    
    if ([obj isKindOfClass:[JPBoxing class]]) return [obj unbox];
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [obj count]; i ++) {
            [newArr addObject:formatJSToOC(jsval[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        if (obj[@"__obj"]) {
            id ocObj = [obj objectForKey:@"__obj"];
            if ([ocObj isKindOfClass:[JPBoxing class]]) return [ocObj unbox];
            return ocObj;
        }
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            [newDict setObject:formatJSToOC(jsval[key]) forKey:key];
        }
        return newDict;
    }
    return obj;
}

static id _formatOCToJSList(NSArray *list)
{
    NSMutableArray *arr = [NSMutableArray new];
    for (id obj in list) {
        [arr addObject:formatOCToJS(obj)];
    }
    return arr;
}

static NSDictionary *_wrapObj(id obj)
{
    if (!obj || obj == _nilObj) {
        return @{@"__isNil": @(YES)};
    }
    return @{@"__clsName": NSStringFromClass([obj class]), @"__obj": obj};
}

static id _unboxOCObjectToJS(id obj)
{
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [obj count]; i ++) {
            [newArr addObject:_unboxOCObjectToJS(obj[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            [newDict setObject:_unboxOCObjectToJS(obj[key]) forKey:key];
        }
        return newDict;
    }
    if ([obj isKindOfClass:[NSString class]] ||[obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:NSClassFromString(@"NSBlock")]) {
        return obj;
    }
    return _wrapObj(obj);
}
@end


@implementation JPExtension

+ (void)main:(JSContext *)context{}

+ (void *)formatPointerJSToOC:(JSValue *)val
{
    id obj = [val toObject];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        if (obj[@"__obj"] && [obj[@"__obj"] isKindOfClass:[JPBoxing class]]) {
            return [(JPBoxing *)(obj[@"__obj"]) unboxPointer];
        } else {
            return NULL;
        }
    } else if (![val toBool]) {
        return NULL;
    } else{
        return [((JPBoxing *)[val toObject]) unboxPointer];
    }
}

+ (id)formatPointerOCToJS:(void *)pointer
{
    return formatOCToJS([JPBoxing boxPointer:pointer]);
}

+ (id)formatJSToOC:(JSValue *)val
{
    if (![val toBool]) {
        return nil;
    }
    return formatJSToOC(val);
}

+ (id)formatOCToJS:(id)obj
{
    return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[formatOCToJS(obj)]];
}

+ (int)sizeOfStructTypes:(NSString *)structTypes
{
    return sizeOfStructTypes(structTypes);
}

+ (void)getStructDataWidthDict:(void *)structData dict:(NSDictionary *)dict structDefine:(NSDictionary *)structDefine
{
    return getStructDataWithDict(structData, dict, structDefine);
}

+ (NSDictionary *)getDictOfStruct:(void *)structData structDefine:(NSDictionary *)structDefine
{
    return getDictOfStruct(structData, structDefine);
}
@end
