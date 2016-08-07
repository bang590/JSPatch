//
//  JPNumber.m
//  JSPatchDemo
//
//  Created by pucheng on 16/7/5.
//  Copyright © 2016年 pucheng. All rights reserved.
//

#import "JPNumber.h"
#import <objc/runtime.h>

@implementation JPNumber

+ (void)main:(JSContext *)context {
    
    // for subclass of NSNumber, e.g. NSDecimalNumber
    context[@"OCNumber"] = ^ id (NSString *clsName, NSString *selName, JSValue *arguments) {
        Class cls = NSClassFromString(clsName);
        SEL sel = NSSelectorFromString(selName);
        if (!cls || !sel) return nil;
        Method m = class_getClassMethod(cls, sel);
        if (!m) return nil;
        
        NSMethodSignature *methodSignature = [cls methodSignatureForSelector:sel];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:cls];
        [invocation setSelector:sel];
        id argumentsObj = [self formatJSToOC: arguments];
        NSUInteger numberOfArguments = methodSignature.numberOfArguments;
        
        for (NSUInteger i = 2; i < numberOfArguments; i++) {
            const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
            id valObj = argumentsObj[i-2];
            switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                    
                #define JP_OCNumber_CASE(_typeString, _type, _selector) \
                    case _typeString: { \
                        _type value = [valObj _selector];  \
                        [invocation setArgument:&value atIndex:i];  \
                        break;  \
                    }
                    
                    JP_OCNumber_CASE('c', char, charValue)
                    JP_OCNumber_CASE('C', unsigned char, unsignedCharValue)
                    JP_OCNumber_CASE('s', short, shortValue)
                    JP_OCNumber_CASE('S', unsigned short, unsignedShortValue)
                    JP_OCNumber_CASE('i', int, intValue)
                    JP_OCNumber_CASE('I', unsigned int, unsignedIntValue)
                    JP_OCNumber_CASE('l', long, longValue)
                    JP_OCNumber_CASE('L', unsigned long, unsignedLongValue)
                    JP_OCNumber_CASE('q', long long, longLongValue)
                    JP_OCNumber_CASE('Q', unsigned long long, unsignedLongLongValue)
                    JP_OCNumber_CASE('f', float, floatValue)
                    JP_OCNumber_CASE('d', double, doubleValue)
                    JP_OCNumber_CASE('B', BOOL, boolValue)
                default:
                    [invocation setArgument:&valObj atIndex:i];
            }
        }
        [invocation invoke];
        void *result;
        [invocation getReturnValue:&result];
        id returnValue = (__bridge id)result;
        /**
         * must be boxed in JPBoxing.
         * Otherwise when calling functions in JS, the number valued 0 which is considered as null will call a class function rather than a instance function in JSPatch.js
         */
        JPBoxing *box = [[JPBoxing alloc] init];
        box.obj = returnValue;
        return  @{@"__obj": box, @"__clsName": clsName};
    };
    
    context[@"toOCNumber"] = ^ id (JSValue *value) {
        id obj = [value toObject];
        if (!obj || ![obj isKindOfClass:[NSNumber class]]) {
            return nil;
        }
        JPBoxing *box = [[JPBoxing alloc] init];
        box.obj = obj;
        return  @{@"__obj": box, @"__clsName": NSStringFromClass([obj class])};
    };
    
    context[@"toJSNumber"] = ^ NSNumber *(JSValue *value) {
        NSDictionary *dict = [value toDictionary];
        if (dict) {
            return [(JPBoxing *)dict[@"__obj"] unbox];
        }
        return 0;
    };
}

@end
