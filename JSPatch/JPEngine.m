//
//  JPEngine.m
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPEngine.h"
#import <objc/runtime.h>
#import <objc/message.h>

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
    JSContext *context = [[JSContext alloc] init];
    _cacheArguments = [[NSMutableDictionary alloc] init];
    
    context[@"_OC_defineClass"] = ^(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods) {
        return defineClass(classDeclaration, instanceMethods, classMethods);
    };
    
    context[@"_OC_callI"] = ^id(id obj, NSString *selectorName, NSArray *arguments, BOOL isSuper) {
        return callSelector(nil, selectorName, arguments, obj, isSuper);
    };
    context[@"_OC_callC"] = ^id(NSString *className, NSString *selectorName, NSArray *arguments) {
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
    _nullObj = [[NSObject alloc] init];
    context[@"_OC_null"] = toJSObj(_nullObj);
    
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
            NSLog(@"JSPatch.log: %@", jsVal);
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

static NSDictionary *defineClass(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods)
{
    NSArray *clsArr = [classDeclaration componentsSeparatedByString:@":"];
    NSString *className = trim(clsArr[0]);
    NSString *superClassName = clsArr.count > 1 ? trim(clsArr[1]) : @"NSObject";
    
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
                overrideMethod(currCls, selectorName, jsMethod, !isInstance);
            }
             else {
                addNewMethod(currCls, selectorName, jsMethod, numberOfArg, !isInstance);
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
    id obj = [ret toObject]; \
    if ([obj isKindOfClass:[NSNull class]]) return nil;  \
    return obj;

JPMETHOD_IMPLEMENTATION_RET(void, v, nil)
JPMETHOD_IMPLEMENTATION_RET(id, id, JPMETHOD_RET_ID)
JPMETHOD_IMPLEMENTATION_RET(CGRect, rect, return dictToRect([ret toObject]))
JPMETHOD_IMPLEMENTATION_RET(CGSize, size, return dictToSize([ret toObject]))
JPMETHOD_IMPLEMENTATION_RET(CGPoint, point, return dictToPoint([ret toObject]))
JPMETHOD_IMPLEMENTATION_RET(NSRange, range, return dictToRange([ret toObject]))
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

#define JPMETHOD_NEW_IMPLEMENTATION_NAME(_argCount) JPMethodNewImplementation_##_argCount
#define JPMETHOD_NEW_IMPLEMENTATION_ARG_0 (id slf, SEL selector)
#define JPMETHOD_NEW_IMPLEMENTATION_ARG_1 (id slf, SEL selector, id obj1)
#define JPMETHOD_NEW_IMPLEMENTATION_ARG_2 (id slf, SEL selector, id obj1, id obj2)
#define JPMETHOD_NEW_IMPLEMENTATION_ARG_3 (id slf, SEL selector, id obj1, id obj2, id obj3)
#define JPMETHOD_NEW_IMPLEMENTATION_ARG_4 (id slf, SEL selector, id obj1, id obj2, id obj3, id obj4)
#define JPMETHOD_NEW_IMPLEMENTATION_ARG_5 (id slf, SEL selector, id obj1, id obj2, id obj3, id obj4, id obj5)

#define JPMETHOD_NEW_IMPLEMENTATION(_argCount, _argArr)   \
static id JPMETHOD_NEW_IMPLEMENTATION_NAME(_argCount) JPMETHOD_NEW_IMPLEMENTATION_ARG_##_argCount { \
    NSString *selectorName = NSStringFromSelector(selector);    \
    NSString *clsName = NSStringFromClass([slf class]); \
    JSValue *ret = [_JSOverideMethods[clsName][selectorName] callWithArguments:formatOCObj(@[slf _argArr])];    \
    return [ret toObject]; \
}

#define COMMA ,

JPMETHOD_NEW_IMPLEMENTATION(0, );
JPMETHOD_NEW_IMPLEMENTATION(1, COMMA obj1);
JPMETHOD_NEW_IMPLEMENTATION(2, COMMA obj1 COMMA obj2);
JPMETHOD_NEW_IMPLEMENTATION(3, COMMA obj1 COMMA obj2 COMMA obj3);
JPMETHOD_NEW_IMPLEMENTATION(4, COMMA obj1 COMMA obj2 COMMA obj3 COMMA obj4);
JPMETHOD_NEW_IMPLEMENTATION(5, COMMA obj1 COMMA obj2 COMMA obj3 COMMA obj4 COMMA obj5);


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
            default: {
                NSLog(@"error type %s", argumentType);
                break;
            }
        }
    }
    
    @synchronized(_context) {
        _TMPInvocationArguments = formatOCObj(argList);

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

static void overrideMethod(Class cls, NSString *selectorName, JSValue *function, BOOL isClassMethod)
{
    SEL selector = NSSelectorFromString(selectorName);
    NSMethodSignature *methodSignature = [cls instanceMethodSignatureForSelector:selector];
    Method method = class_getInstanceMethod(cls, selector);
    char *typeDescription = (char *)method_getTypeEncoding(method);
    
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
    SEL newForwardSelector = @selector(ORIGforwardInvocation:);
    if (!class_respondsToSelector(cls, newForwardSelector)) {
        IMP originalForwardImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)JPForwardInvocation, "v@:@");
        class_addMethod(cls, newForwardSelector, originalForwardImp, "v@:@");
    }
#pragma clang diagnostic pop

    NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", selectorName];
    SEL originalSelector = NSSelectorFromString(originalSelectorName);
    if(!class_respondsToSelector(cls, originalSelector)) {
        class_addMethod(cls, originalSelector, originalImp, typeDescription);
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

static void addNewMethod(Class cls, NSString *selectorName, JSValue *function, int argCount, BOOL isClassMethod)
{
    NSString *clsName = NSStringFromClass(cls);
    _initJPOverideMethods(clsName);
    _JSOverideMethods[clsName][selectorName] = function;
    
    SEL selector = NSSelectorFromString(selectorName);
    IMP JPImplementation = (IMP)JPMETHOD_NEW_IMPLEMENTATION_NAME(0);
    switch (argCount) {
    #define JPMETHOD_NEW_CASE(_argCount) \
        case _argCount: \
            JPImplementation = (IMP)JPMETHOD_NEW_IMPLEMENTATION_NAME(_argCount);    \
            break;
            
        JPMETHOD_NEW_CASE(0)
        JPMETHOD_NEW_CASE(1)
        JPMETHOD_NEW_CASE(2)
        JPMETHOD_NEW_CASE(3)
        JPMETHOD_NEW_CASE(4)
        JPMETHOD_NEW_CASE(5)
    }
    NSMutableString *typeDescStr = [@"@@:" mutableCopy];
    for (int i = 0; i < argCount; i ++) {
        [typeDescStr appendString:@"@"];
    }
    class_addMethod(cls, selector, JPImplementation, [typeDescStr cStringUsingEncoding:NSUTF8StringEncoding]);
}

#pragma mark -

static id callSelector(NSString *className, NSString *selectorName, NSArray *arguments, id instance, BOOL isSuper) {
    Class cls = className ? NSClassFromString(className) : [instance class];
    SEL selector = NSSelectorFromString(selectorName);
    
    if (isSuper) {
        NSString *superSelectorName = [NSString stringWithFormat:@"SUPER_%@", selectorName];
        SEL superSelector = NSSelectorFromString(superSelectorName);
        
        Class superCls = [cls superclass];
        Method superMethod = class_getInstanceMethod(superCls, selector);
        IMP superIMP = method_getImplementation(superMethod);
        
        class_addMethod(cls, superSelector, superIMP, method_getTypeEncoding(superMethod));
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
            id __unsafe_unretained tempResultSet;
            [invocation getReturnValue:&tempResultSet];
            returnValue = tempResultSet;
            
            return formatOCObj(returnValue);
            
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
                }
                    break;
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

#define BLK_ADD_OBJ(_paramName) [list addObject:formatOCObj((__bridge id)_paramName)];
#define BLK_ADD_INT(_paramName) [list addObject:formatOCObj([NSNumber numberWithLongLong:(long long)_paramName])];

#define BLK_TRAITS_ARG(_idx, _paramName) \
    if (typeIsObject(trim(argTypes[_idx]))) {  \
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
    if (count == 3) {
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

static id formatOCObj(id obj) {
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [obj count]; i ++) {
            [newArr addObject:formatOCObj(obj[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            if ([key isEqualToString:@"__c"]) continue;
            [newDict setObject:formatOCObj(obj[key]) forKey:key];
        }
        return newDict;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSBlock")]) {
        return obj;
    }
    
    return toJSObj(obj);
}

static BOOL typeIsObject(NSString *typeString) {
    return [typeString rangeOfString:@"*"].location != NSNotFound || [typeString isEqualToString:@"id"];
}

static NSDictionary *toJSObj(id obj)
{
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        return @{@"__isNull": @(YES)};
    }
    return @{@"__isObj": @(YES), @"cls": NSStringFromClass([obj class]), @"obj": obj};
}
@end
