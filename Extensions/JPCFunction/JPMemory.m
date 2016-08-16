//
//  JPMemory.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPMemory.h"

@implementation JPMemory

+ (void)main:(JSContext *)context
{
    context[@"memset"] = ^void(JSValue *jsVal, int ch,size_t n) {
        memset([self formatPointerJSToOC:jsVal], ch, n);
    };
    
    context[@"memmove"] = ^id(JSValue *des, JSValue *src, size_t n) {
        void *ret = memmove([self formatPointerJSToOC:des], [self formatPointerJSToOC:src], n);
        return [self formatPointerOCToJS:ret];
    };
    
    context[@"memcpy"] = ^id(JSValue *des, JSValue *src, size_t n) {
        void *ret = memcpy([self formatPointerJSToOC:des], [self formatPointerJSToOC:src], n);
        return [self formatPointerOCToJS:ret];
    };
    
    context[@"malloc"] = ^id(size_t size) {
        void *m = malloc(size);
        return [self formatPointerOCToJS:m];
    };
    
    context[@"free"] = ^void(JSValue *jsVal) {
        void *m = [self formatPointerJSToOC:jsVal];
        free(m);
    };
    
    context[@"pval"] = ^id(JSValue *jsVal) {
        void *m = [self formatPointerJSToOC:jsVal];
        id obj = *((__unsafe_unretained id *)m);
        return [self formatOCToJS:obj];
    };
    
    context[@"getPointer"] = ^id(JSValue *jsVal) {
        void **p = malloc(sizeof(void *));
        void *pointer = [self formatPointerJSToOC:jsVal];
        if (pointer != NULL) {
            *p = pointer;
        } else {
            id obj = [self formatJSToOC:jsVal];
            *p = (__bridge void*)obj;
        }
        return [self formatPointerOCToJS:p];
    };
    
    context[@"pvalBool"] = ^id(JSValue *jsVal) {
        void *m = [self formatPointerJSToOC:jsVal];
        BOOL b = *((BOOL *)m);
        return [self formatOCToJS:[NSNumber numberWithBool:b]];
    };
    
    __weak JSContext *weakCtx = context;
    context[@"sizeof"] = ^size_t(JSValue *jsVal) {
        NSString *typeName = [jsVal toString];
        
        if ([typeName isEqualToString:@"id"]) return sizeof(id);
        if ([typeName isEqualToString:@"CGRect"]) return sizeof(CGRect);
        if ([typeName isEqualToString:@"CGPoint"]) return sizeof(CGPoint);
        if ([typeName isEqualToString:@"CGSize"]) return sizeof(CGSize);
        if ([typeName isEqualToString:@"NSRange"]) return sizeof(NSRange);
        
        @synchronized (weakCtx) {
            NSDictionary *structDefine = [JPExtension registeredStruct][typeName];
            if (structDefine) {
                return [self sizeOfStructTypes:structDefine[@"types"]];
            }
        }
        return 0;
    };
    
    context[@"__bridge_id"] = ^id(JSValue *jsVal) {
        void *p = [self formatPointerJSToOC:jsVal];
        id obj = (__bridge id)p;
        return [self formatOCToJS:obj];
    };
    
    context[@"CFRelease"] = ^void(JSValue *jsVal) {
        CFRelease([self formatPointerJSToOC:jsVal]);
    };
    
    context[@"CFRetain"] = ^void(JSValue *jsVal) {
        CFRetain([self formatPointerJSToOC:jsVal]);
    };
    
    context[@"assignPointer"] = ^void(JSValue *jsVal, JSValue *value) {
        void *m = [self formatPointerJSToOC:jsVal];
        id obj = [self formatJSToOC:value];
        *((__unsafe_unretained id *)m) = obj;
    };
    
    context[@"assignScalarTypePointer"] = ^void(JSValue *jsVal, JSValue *value, NSString *type) {
        void *pointer = [self formatPointerJSToOC:jsVal];
        char *typeChar = (char*)[type UTF8String];
        
        switch (typeChar[0]) {
            #define JP_ASSIGN_SCALAR_CASE(_typeChar, _type, _method) \
            case _typeChar: {   \
                NSNumber *num = [value toNumber]; \
                (*(_type *)pointer) = [num _method]; \
                break;  \
            }
                
            JP_ASSIGN_SCALAR_CASE('s', short, shortValue)
            JP_ASSIGN_SCALAR_CASE('S', unsigned short, unsignedShortValue)
            JP_ASSIGN_SCALAR_CASE('i', int, intValue)
            JP_ASSIGN_SCALAR_CASE('I', unsigned int, unsignedIntValue)
            JP_ASSIGN_SCALAR_CASE('l', long, longValue)
            JP_ASSIGN_SCALAR_CASE('L', unsigned long, unsignedLongValue)
            JP_ASSIGN_SCALAR_CASE('q', long long, longLongValue)
            JP_ASSIGN_SCALAR_CASE('Q', unsigned long long, unsignedLongLongValue)
            JP_ASSIGN_SCALAR_CASE('f', float, floatValue)
            JP_ASSIGN_SCALAR_CASE('d', double, doubleValue)
            JP_ASSIGN_SCALAR_CASE('B', BOOL, boolValue)
            case 'c': 
            case 'C': {
                NSString *str = [value toString];
                (*(char *)pointer) = *[str cStringUsingEncoding:NSUTF8StringEncoding];
                break;
            }
            default: {
                break;
            }
        }
    };
    
    context[@"autoreleasepool"] = ^void(JSValue *cb) {
        @autoreleasepool {
            [cb callWithArguments:nil];
        }
    };
}



@end
