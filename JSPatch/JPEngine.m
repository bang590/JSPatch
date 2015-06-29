//  JPEngine.m
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPEngine.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface JPBoxing : NSObject
@property (nonatomic) id obj;
@property (nonatomic) void *pointer;
@property (nonatomic) Class cls;
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

- (id)unbox
{
    if (self.obj) return self.obj;
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

#pragma mark - APIS

static NSString *_regexStr = @"\\.\\s*(\\w+)\\s*\\(";
static NSString *_replaceStr = @".__c(\"$1\")(";
static NSRegularExpression* _regex;
static NSObject *_nullObj;

+ (JSContext *)context
{
    return _context;
}

+ (JSValue *)evaluateScript:(NSString *)script
{
    if (!script) {
        NSAssert(NO, @"script is nil");
        return nil;
    }
    
    if (!_regex) {
        _regex = [NSRegularExpression regularExpressionWithPattern:_regexStr options:0 error:nil];
    }
    NSString *formatedScript = [NSString stringWithFormat:@"try{%@}catch(e){_OC_catch(e.message, e.stack)}", [_regex stringByReplacingMatchesInString:script options:0 range:NSMakeRange(0, script.length) withTemplate:_replaceStr]];
    return [_context evaluateScript:formatedScript];
}


+ (void)startEngine
{
    if (_context) {
        return;
    }
    
    JSContext *context = [[JSContext alloc] init];
    _cacheArguments = [[NSMutableDictionary alloc] init];
    
    context[@"_OC_defineClass"] = ^(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods) {
        return defineClass(classDeclaration, instanceMethods, classMethods);
    };
    
    context[@"_OC_callI"] = ^id(JSValue *obj, NSString *selectorName, JSValue *arguments, BOOL isSuper) {
        return callSelector(nil, selectorName, arguments, obj, isSuper);
    };
    context[@"_OC_callC"] = ^id(NSString *className, NSString *selectorName, JSValue *arguments) {
        return callSelector(className, selectorName, arguments, nil, NO);
    };
    context[@"_OC_getBlockArguments"] = ^id(NSNumber *idx) {
        @synchronized(_cacheArguments) {
            if (_cacheArguments[idx]) {
                id args = _cacheArguments[idx];
                [_cacheArguments removeObjectForKey:idx];
                return args;
            }
            return nil;
        }
    };
    context[@"_OC_formatJSToOC"] = ^id(JSValue *obj) {
        return formatJSToOC(obj);
    };
    
    _nullObj = [[NSObject alloc] init];
    context[@"_OC_null"] = formatOCToJS(_nullObj);
    
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

    context[@"_OC_log"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            NSLog(@"JSPatch.log: %@", formatJSToOC(jsVal));
        }
    };
    
    context[@"_OC_free"] = ^(JSValue *jsVal) {
        JPBoxing *obj = formatJSToOC(jsVal);
        if ([obj isKindOfClass:[JPBoxing class]] && obj.pointer) {
            free(obj.pointer);
        }
    };
    
    context[@"_OC_catch"] = ^(JSValue *msg, JSValue *stack) {
        NSAssert(NO, @"js exception, \nmsg: %@, \nstack: \n %@", [msg toObject], [stack toObject]);
    };
    
    context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        NSAssert(NO, @"js exception: %@", exception);
    };
    
    _context = context;
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"JSPatch" ofType:@"js"];
    NSAssert(path, @"can't find JSPatch.js");
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [_context evaluateScript:jsCore];
}

#pragma mark - Implements

static NSMutableDictionary *_JSOverideMethods;
static NSArray *_TMPInvocationArguments;
static NSRegularExpression *countArgRegex;
static NSMutableDictionary *_propKeys;

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
        if(!superCls){
            return @{@"cls": @""};
        }
        cls = objc_allocateClassPair(superCls, className.UTF8String, 0);
        objc_registerClassPair(cls);
    }
    
    for (int i = 0; i < 2; i ++) {
        BOOL isInstance = i == 0;
        JSValue *jsMethods = isInstance ? instanceMethods: classMethods;
        
        Class currCls = isInstance ? cls: objc_getMetaClass(className.UTF8String);
        NSDictionary *methodDict = [jsMethods toDictionary];
        for (NSString *jsMethodName in methodDict.allKeys) {
            if ([jsMethodName isEqualToString:@"__c"]) {
                continue;
            }
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

static JSValue* getJSFunctionInObjectHierachy(id slf, SEL selector)
{
    NSString *selectorName = NSStringFromSelector(selector);
    Class cls = [slf class];
    NSString *clsName = NSStringFromClass(cls);
    JSValue *func = _JSOverideMethods[clsName][selectorName];
    while (!func) {
        cls = class_getSuperclass(cls);
        if (!cls) {
            NSCAssert(NO, @"warning can not find selector %@", selectorName);
            return nil;
        }
        clsName = NSStringFromClass(cls);
        func = _JSOverideMethods[clsName][selectorName];
    }
    return func;
}

#define JPMETHOD_IMPLEMENTATION(_type, _typeString, _typeSelector) \
    JPMETHOD_IMPLEMENTATION_RET(_type, _typeString, return [[ret toObject] _typeSelector]) \

#define JPMETHOD_IMPLEMENTATION_RET(_type, _typeString, _ret) \
static _type JPMETHOD_IMPLEMENTATION_NAME(_typeString) (id slf, SEL selector) {    \
    JSValue *fun = getJSFunctionInObjectHierachy(slf, selector);    \
    JSValue *ret = [fun callWithArguments:_TMPInvocationArguments];  \
    _ret;    \
}   \

#define JPMETHOD_IMPLEMENTATION_NAME(_typeString) JPMethodImplement_##_typeString

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

#define JPMETHOD_RET_ID \
    id obj = formatJSToOC(ret); \
    if ([obj isKindOfClass:[NSNull class]]) return nil;  \
    return obj;

#define JPMETHOD_RET_STRUCT(_methodName)    \
    id dict = formatJSToOC(ret);   \
    return _methodName(dict);

#define JPMETHOD_RET_POINTER    \
    id obj = formatJSToOC(ret); \
    if ([obj isKindOfClass:[JPBoxing class]]) { \
        return [((JPBoxing *)obj) unboxPointer]; \
    }   \
    return NULL;

#define JPMETHOD_RET_CLASS    \
    id obj = formatJSToOC(ret); \
    if ([obj isKindOfClass:[JPBoxing class]]) { \
        return [((JPBoxing *)obj) unboxClass]; \
    }   \
    return nil;

#define JPMETHOD_RET_SEL    \
    id obj = formatJSToOC(ret); \
    if ([obj isKindOfClass:[NSString class]]) { \
        return NSSelectorFromString(obj); \
    }   \
    return nil;

JPMETHOD_IMPLEMENTATION_RET(void, v, nil)
JPMETHOD_IMPLEMENTATION_RET(id, id, JPMETHOD_RET_ID)
JPMETHOD_IMPLEMENTATION_RET(void *, pointer, JPMETHOD_RET_POINTER)
JPMETHOD_IMPLEMENTATION_RET(Class, cls, JPMETHOD_RET_CLASS)
JPMETHOD_IMPLEMENTATION_RET(SEL, sel, JPMETHOD_RET_SEL)
JPMETHOD_IMPLEMENTATION_RET(CGRect, rect, JPMETHOD_RET_STRUCT(dictToRect))
JPMETHOD_IMPLEMENTATION_RET(CGSize, size, JPMETHOD_RET_STRUCT(dictToSize))
JPMETHOD_IMPLEMENTATION_RET(CGPoint, point, JPMETHOD_RET_STRUCT(dictToPoint))
JPMETHOD_IMPLEMENTATION_RET(NSRange, range, JPMETHOD_RET_STRUCT(dictToRange))
JPMETHOD_IMPLEMENTATION(char, c, charValue)
JPMETHOD_IMPLEMENTATION(unsigned char, C, unsignedCharValue)
JPMETHOD_IMPLEMENTATION(short, s, shortValue)
JPMETHOD_IMPLEMENTATION(unsigned short, S, unsignedShortValue)
JPMETHOD_IMPLEMENTATION(int, i, intValue)
JPMETHOD_IMPLEMENTATION(unsigned int, I, unsignedIntValue)
JPMETHOD_IMPLEMENTATION(long, l, longValue)
JPMETHOD_IMPLEMENTATION(unsigned long, L, unsignedLongValue)
JPMETHOD_IMPLEMENTATION(long long, q, longLongValue)
JPMETHOD_IMPLEMENTATION(unsigned long long, Q, unsignedLongLongValue)
JPMETHOD_IMPLEMENTATION(float, f, floatValue)
JPMETHOD_IMPLEMENTATION(double, d, doubleValue)
JPMETHOD_IMPLEMENTATION(BOOL, B, boolValue)

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
                    [argList addObject:(arg ? [arg copy]: [NSNull null])];
                } else {
                    [argList addObject:(arg ? arg: [NSNull null])];
                }
                break;
            }
            case '{': {
                NSString *typeString = [NSString stringWithUTF8String:argumentType];
                #define JP_FWD_ARG_STRUCT(_type, _transFunc) \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    _type arg; \
                    [invocation getArgument:&arg atIndex:i];    \
                    [argList addObject:_transFunc(arg)];  \
                    break; \
                }
                JP_FWD_ARG_STRUCT(CGRect, rectToDictionary)
                JP_FWD_ARG_STRUCT(CGPoint, pointToDictionary)
                JP_FWD_ARG_STRUCT(CGSize, sizeToDictionary)
                JP_FWD_ARG_STRUCT(NSRange, rangeToDictionary)
                break;
            }
            case ':': {
                SEL selector;
                [invocation getArgument:&selector atIndex:i];
                NSString *selectorName = NSStringFromSelector(selector);
                [argList addObject:(selectorName ? selectorName: [NSNull null])];
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
    
    @synchronized(_context) {
        _TMPInvocationArguments = formatOCToJSList(argList);

        [invocation setSelector:JPSelector];
        [invocation invoke];
        
        _TMPInvocationArguments = nil;
    }
}

static void _initJPOverideMethods(NSString *clsName) {
    if (!_JSOverideMethods) {
        _JSOverideMethods = [[NSMutableDictionary alloc] init];
    }
    if (!_JSOverideMethods[clsName]) {
        _JSOverideMethods[clsName] = [[NSMutableDictionary alloc] init];
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
    NSString *clsName = NSStringFromClass(cls);

    if (!_JSOverideMethods[clsName][JPSelectorName]) {
        _initJPOverideMethods(clsName);
        _JSOverideMethods[clsName][JPSelectorName] = function;
        const char *returnType = [methodSignature methodReturnType];
        IMP JPImplementation;
        
        switch (returnType[0]) {
            #define JP_OVERRIDE_RET_CASE(_type, _typeChar)   \
            case _typeChar : { \
                JPImplementation = (IMP)JPMETHOD_IMPLEMENTATION_NAME(_type); \
                break;  \
            }
            JP_OVERRIDE_RET_CASE(v, 'v')
            JP_OVERRIDE_RET_CASE(id, '@')
            JP_OVERRIDE_RET_CASE(c, 'c')
            JP_OVERRIDE_RET_CASE(C, 'C')
            JP_OVERRIDE_RET_CASE(s, 's')
            JP_OVERRIDE_RET_CASE(S, 'S')
            JP_OVERRIDE_RET_CASE(i, 'i')
            JP_OVERRIDE_RET_CASE(I, 'I')
            JP_OVERRIDE_RET_CASE(l, 'l')
            JP_OVERRIDE_RET_CASE(L, 'L')
            JP_OVERRIDE_RET_CASE(q, 'q')
            JP_OVERRIDE_RET_CASE(Q, 'Q')
            JP_OVERRIDE_RET_CASE(f, 'f')
            JP_OVERRIDE_RET_CASE(d, 'd')
            JP_OVERRIDE_RET_CASE(B, 'B')
            JP_OVERRIDE_RET_CASE(pointer, '^')
            JP_OVERRIDE_RET_CASE(pointer, '*')
            JP_OVERRIDE_RET_CASE(cls, '#')
            JP_OVERRIDE_RET_CASE(sel, ':')
            
            case '{': {
                NSString *typeString = [NSString stringWithUTF8String:returnType];
                
                #define JP_OVERRIDE_RET_STRUCT(_type, _funcSuffix) \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    JPImplementation = (IMP)JPMETHOD_IMPLEMENTATION_NAME(_funcSuffix); \
                    break;  \
                }
                JP_OVERRIDE_RET_STRUCT(CGRect, rect)
                JP_OVERRIDE_RET_STRUCT(CGPoint, point)
                JP_OVERRIDE_RET_STRUCT(CGSize, size)
                JP_OVERRIDE_RET_STRUCT(NSRange, range)
                
                break;
            }
            default: {
                JPImplementation = (IMP)JPMETHOD_IMPLEMENTATION_NAME(v);
                break;
            }
        }
        class_addMethod(cls, JPSelector, JPImplementation, typeDescription);
    }
}

#pragma mark -

static id callSelector(NSString *className, NSString *selectorName, JSValue *arguments, JSValue *instance, BOOL isSuper)
{
    if (instance) instance = formatJSToOC(instance);
    arguments = formatJSToOC(arguments);
    
    if (instance && [selectorName isEqualToString:@"toJS"]) {
        if ([instance isKindOfClass:[NSString class]] || [instance isKindOfClass:[NSDictionary class]] || [instance isKindOfClass:[NSArray class]]) {
            return unboxOCObjectToJS(instance);
        }
    }

    Class cls = className ? NSClassFromString(className) : [instance class];
    SEL selector = NSSelectorFromString(selectorName);
    
    if (isSuper) {
        NSString *superSelectorName = [NSString stringWithFormat:@"SUPER_%@", selectorName];
        SEL superSelector = NSSelectorFromString(superSelectorName);
        
        Class superCls = [cls superclass];
        Method superMethod = class_getInstanceMethod(superCls, selector);
        IMP superIMP = method_getImplementation(superMethod);
        
        class_addMethod(cls, superSelector, superIMP, method_getTypeEncoding(superMethod));
        
        NSString *JPSelectorName = [NSString stringWithFormat:@"_JP%@", selectorName];
        JSValue *overideFunction = _JSOverideMethods[NSStringFromClass(superCls)][JPSelectorName];
        if (overideFunction) {
            overrideMethod(cls, superSelectorName, overideFunction, NO, NULL);
        }
        
        selector = superSelector;
    }
    
    NSInvocation *invocation;
    NSMethodSignature *methodSignature;
    if (instance) {
        methodSignature = [cls instanceMethodSignatureForSelector:selector];
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
        id valObj = arguments[i-2];
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
                if (![valObj isEqual:[NSNull null]]) {
                    value = NSSelectorFromString(valObj);
                }
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '{': {
                NSString *typeString = [NSString stringWithUTF8String:argumentType];
                #define JP_CALL_ARG_STRUCT(_type, _transFunc) \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    _type value = _transFunc(valObj);  \
                    [invocation setArgument:&value atIndex:i];  \
                    break; \
                }
                JP_CALL_ARG_STRUCT(CGRect, dictToRect)
                JP_CALL_ARG_STRUCT(CGPoint, dictToPoint)
                JP_CALL_ARG_STRUCT(CGSize, dictToSize)
                JP_CALL_ARG_STRUCT(NSRange, dictToRange)
                
                break;
            }
            case '*':
            case '^': {
                if ([valObj isKindOfClass:[JPBoxing class]]) {
                    void *value = [((JPBoxing *)valObj) unboxPointer];
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
                if ([valObj isEqual:[NSNull null]]) {
                    valObj = nil;
                    [invocation setArgument:&valObj atIndex:i];
                    break;
                }
                static const char *blockType = @encode(typeof(^{}));
                if (!strcmp(argumentType, blockType)) {
                    __autoreleasing id cb = genCallbackBlock(valObj);
                    [invocation setArgument:&cb atIndex:i];
                } else {
                    [invocation setArgument:&valObj atIndex:i];
                }
            }
        }
    }
    
    [invocation invoke];
    const char *returnType = [methodSignature methodReturnType];
    id returnValue;
    if (strncmp(returnType, "v", 1) != 0) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];
            if ([selectorName isEqualToString:@"alloc"] || [selectorName isEqualToString:@"new"]) {
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
                    NSString *typeString = [NSString stringWithUTF8String:returnType];
                    #define JP_CALL_RET_STRUCT(_type, _transFunc) \
                    if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                        _type result;   \
                        [invocation getReturnValue:&result];    \
                        return _transFunc(result);    \
                    }
                    JP_CALL_RET_STRUCT(CGRect, rectToDictionary)
                    JP_CALL_RET_STRUCT(CGPoint, pointToDictionary)
                    JP_CALL_RET_STRUCT(CGSize, sizeToDictionary)
                    JP_CALL_RET_STRUCT(NSRange, rangeToDictionary)
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

static NSMutableDictionary *_cacheArguments;
static NSInteger _cacheArgumentsIdx = 0;

static id genCallbackBlock(id valObj)
{
#define BLK_DEFINE_1 cb = ^(void *p0) {
#define BLK_DEFINE_2 cb = ^(void *p0, void *p1) {
#define BLK_DEFINE_3 cb = ^(void *p0, void *p1, void *p2) {
#define BLK_DEFINE_4 cb = ^(void *p0, void *p1, void *p2, void *p3) {

#define BLK_ADD_OBJ(_paramName) [list addObject:formatOCToJS((__bridge id)_paramName)];
#define BLK_ADD_INT(_paramName) [list addObject:formatOCToJS([NSNumber numberWithLongLong:(long long)_paramName])];

#define BLK_TRAITS_ARG(_idx, _paramName) \
    if (blockTypeIsObject(trim(argTypes[_idx]))) {  \
        BLK_ADD_OBJ(_paramName) \
    } else {  \
        BLK_ADD_INT(_paramName) \
    }   \

#define BLK_END \
    NSNumber *jsCallbackID = valObj[@"cbID"];   \
    NSInteger cacheKey = _cacheArgumentsIdx++;  \
    @synchronized(_cacheArguments) {   \
        _cacheArguments[@(cacheKey)] = list;    \
    }   \
    NSString *script = [NSString stringWithFormat:@"_callCB(%@, %@)", jsCallbackID, @(cacheKey)];   \
    [JPEngine evaluateScript:script];   \
};
    
    NSArray *argTypes = [valObj[@"args"] componentsSeparatedByString:@","];
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

#pragma mark - Utils

static NSDictionary *rectToDictionary(CGRect rect)
{
    return @{@"x": @(rect.origin.x), @"y": @(rect.origin.y), @"width": @(rect.size.width), @"height": @(rect.size.height)};
}

static NSDictionary *pointToDictionary(CGPoint point)
{
    return @{@"x": @(point.x), @"y": @(point.y)};
}

static NSDictionary *sizeToDictionary(CGSize size)
{
    return @{@"width": @(size.width), @"height": @(size.height)};
}

static NSDictionary *rangeToDictionary(NSRange range)
{
    return @{@"location": @(range.location), @"length": @(range.length)};
}

static CGRect dictToRect(NSDictionary *dict)
{
    return CGRectMake([dict[@"x"] intValue], [dict[@"y"] intValue], [dict[@"width"] intValue], [dict[@"height"] intValue]);
}

static CGPoint dictToPoint(NSDictionary *dict)
{
    return CGPointMake([dict[@"x"] intValue], [dict[@"y"] intValue]);
}

static CGSize dictToSize(NSDictionary *dict)
{
    return CGSizeMake([dict[@"width"] intValue], [dict[@"height"] intValue]);
}

static NSRange dictToRange(NSDictionary *dict)
{
    return NSMakeRange([dict[@"location"] intValue], [dict[@"length"] intValue]);
}

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static BOOL blockTypeIsObject(NSString *typeString)
{
    return [typeString rangeOfString:@"*"].location != NSNotFound || [typeString isEqualToString:@"id"];
}

#pragma mark - Object format

static id formatOCToJSList(NSArray *list)
{
    NSMutableArray *arr = [NSMutableArray new];
    for (id obj in list) {
        [arr addObject:formatOCToJS(obj)];
    }
    return arr;
}

static id formatOCToJS(id obj)
{
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
        return wrapObj([JPBoxing boxObj:obj]);
    }
    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:NSClassFromString(@"NSBlock")]) {
        return obj;
    }
    return wrapObj(obj);
}

static NSDictionary *wrapObj(id obj)
{
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        return @{@"__isNull": @(YES)};
    }
    return @{@"__clsName": NSStringFromClass([obj class]), @"__obj": obj};
}

static id formatJSToOC(JSValue *jsval)
{
    id obj = [jsval toObject];
    if (!obj) return [NSNull null]; 
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
            if ([key isEqualToString:@"__c"]) continue;
            [newDict setObject:formatJSToOC(jsval[key]) forKey:key];
        }
        return newDict;
    }
    return obj;
}

static id unboxOCObjectToJS(id obj)
{
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [obj count]; i ++) {
            [newArr addObject:unboxOCObjectToJS(obj[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            if ([key isEqualToString:@"__c"]) continue;
            [newDict setObject:unboxOCObjectToJS(obj[key]) forKey:key];
        }
        return newDict;
    }
    if ([obj isKindOfClass:[NSString class]] ||[obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:NSClassFromString(@"NSBlock")]) {
        return obj;
    }
    return wrapObj(obj);
}
@end
