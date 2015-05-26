//
//  JPEngine.m
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPEngine.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface JPEngine ()
@property (nonatomic, strong) NSMutableDictionary *cacheArguments;
@property (nonatomic, assign) NSInteger cacheArgumentsIdx;
@end

@implementation JPEngine

static JSContext *_context;

#pragma mark - APIS

static NSString *regexStr = @"\\.\\s*(\\w+)\\s*\\(";
static NSString *replaceStr = @".__c(\"$1\")(";
static NSRegularExpression* regex;

+ (JSContext *)context
{
    return _context;
}

+ (JSValue *)evaluateScript:(NSString *)script
{
    if (!regex) {
        regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:nil];
    }
    NSString *formatedScript = [NSString stringWithFormat:@"try{%@}catch(e){_OC_catch(e.message, e.stack)}", [regex stringByReplacingMatchesInString:script options:0 range:NSMakeRange(0, script.length) withTemplate:replaceStr]];
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
        if (_cacheArguments[idx]) {
            id args = _cacheArguments[idx];
            [_cacheArguments removeObjectForKey:idx];
            return args;
        }
        return nil;
    };
    
    __weak JSContext *weakCtx = nil;
    context[@"dispatch_after"] = ^(double time, JSValue *func) {
        JSValue *currSelf = weakCtx[@"self"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakCtx[@"self"] = currSelf;
            [func callWithArguments:nil];
            weakCtx[@"self"] = nil;
        });
    };
    context[@"dispatch_async_main"] = ^(JSValue *func) {
        JSValue *currSelf = weakCtx[@"self"];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakCtx[@"self"] = currSelf;
            [func callWithArguments:nil];
            weakCtx[@"self"] = nil;
        });
    };
    context[@"dispatch_sync_main"] = ^(JSValue *func) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [func callWithArguments:nil];
        });
    };
    context[@"dispatch_async_global_queue"] = ^(JSValue *func) {
        JSValue *currSelf = weakCtx[@"self"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            weakCtx[@"self"] = currSelf;
            [func callWithArguments:nil];
            weakCtx[@"self"] = nil;
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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSPatch" ofType:@"js"];
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [_context evaluateScript:jsCore];
}

#pragma mark - Implements

static NSMutableDictionary *_cacheArguments;
static NSInteger _cacheArgumentsIdx = 0;

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
    NSMutableArray *ocInstanceMethods = [[NSMutableArray alloc] init];
    NSMutableArray *ocClassMethods = [[NSMutableArray alloc] init];
    for (int i = 0; i < 2; i ++) {
        BOOL isInstance = i == 0;
        NSMutableArray *methods = isInstance ? ocInstanceMethods: ocClassMethods;
        JSValue *jsMethods = isInstance ? instanceMethods: classMethods;
        
        Class currCls = isInstance ? cls: objc_getMetaClass(className.UTF8String);
        do {
            unsigned int numberOfInstanceMethods = 0;
            Method *instanceMethodsArr = class_copyMethodList(currCls, &numberOfInstanceMethods);
            for (unsigned int i = 0; i < numberOfInstanceMethods; i++) {
                Method method = instanceMethodsArr[i];
                struct objc_method_description *description = method_getDescription(method);
                
                NSString *selectorName = NSStringFromSelector(description->name);
                NSString *jsFuncName = [selectorName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
                if ([jsFuncName characterAtIndex:jsFuncName.length - 1] == '_') {
                    jsFuncName = [jsFuncName substringToIndex:jsFuncName.length - 1];
                }
                JSValue *function = jsMethods[jsFuncName];
                if (!function.isUndefined && ![methods containsObject:jsFuncName]) {
                    overrideMethod(cls, selectorName, jsMethods[jsFuncName], !isInstance);
                    [methods addObject:jsFuncName];
                }
            }
            currCls = [currCls superclass];
        } while (currCls);
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_addMethod(cls, @selector(getProp:), (IMP)getPropIMP, "@24@0:8@16");
    class_addMethod(cls, @selector(setProp:forKey:), (IMP)setPropIMP, "v32@0:8@16@24");
#pragma clang diagnostic pop

    return @{@"cls": className, @"instMethods": ocInstanceMethods, @"clsMethods": ocClassMethods};
}

static NSMutableDictionary *_JSOverideMethods;
static NSArray *_TMPInvocationArguments;

#define JPMETHOD_IMPLEMENTATION(_type, _typeString, _typeSelector) \
    JPMETHOD_IMPLEMENTATION_RET(_type, _typeString, return [[ret toObject] _typeSelector]) \

#define JPMETHOD_IMPLEMENTATION_RET(_type, _typeString, _ret) \
static _type JPMETHOD_IMPLEMENTATION_NAME(_typeString) (id slf, SEL selector) {    \
    NSString *selectorName = NSStringFromSelector(selector);    \
    NSString *clsName = NSStringFromClass([slf class]);\
    JSValue *ret = [_JSOverideMethods[clsName][selectorName] callWithArguments:_TMPInvocationArguments]; \
    _ret;    \
}   \

#define JPMETHOD_IMPLEMENTATION_NAME(_typeString) JPMethodImplement_##_typeString


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

JPMETHOD_IMPLEMENTATION_RET(void, v, nil)
JPMETHOD_IMPLEMENTATION_RET(id, id, return [ret toObject])
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
    if (!class_isMetaClass(object_getClass(slf))) {
        [argList addObject:slf];
    }
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
                void *arg;
                [invocation getArgument:&arg atIndex:i];
                static const char *blockType = @encode(typeof(^{}));
                if (!strcmp(argumentType, blockType)) {
                    [argList addObject:[(__bridge id)arg copy]];
                } else {
                    [argList addObject:(__bridge id)arg];
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
    _TMPInvocationArguments = formatOCObj(argList);

    [invocation setSelector:JPSelector];
    [invocation invoke];
    
    _TMPInvocationArguments = nil;
}

static void overrideMethod(Class cls, NSString *selectorName, JSValue *function, BOOL isClassMethod)
{
    SEL selector = NSSelectorFromString(selectorName);
    NSMethodSignature *methodSignature = isClassMethod ? [cls methodSignatureForSelector:selector]: [cls instanceMethodSignatureForSelector:selector];
    Method method = isClassMethod ? class_getClassMethod(cls, selector) : class_getInstanceMethod(cls, selector);
    char *typeDescription = (char *)method_getTypeEncoding(method);
    
    if (isClassMethod) {
        cls = objc_getMetaClass(object_getClassName(cls));
    }
    
    IMP originalImp = class_respondsToSelector(cls, selector) ? class_getMethodImplementation(cls, selector) : NULL;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_replaceMethod(cls, selector, class_getMethodImplementation(cls, @selector(__JPNONImplementSelector)), typeDescription);

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
    if(!class_respondsToSelector(cls, JPSelector)) {
        NSString *clsName = NSStringFromClass(cls);
        if (!_JSOverideMethods) {
            _JSOverideMethods = [[NSMutableDictionary alloc] init];
        }
        if (!_JSOverideMethods[clsName]) {
            _JSOverideMethods[clsName] = [[NSMutableDictionary alloc] init];
        }
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
                SEL value = NSSelectorFromString(valObj);
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
    _cacheArguments[@(cacheKey)] = list;    \
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
    if (!obj) return nil;
    return @{@"__isObj": @(YES), @"cls": NSStringFromClass([obj class]), @"obj": obj};
}
@end
