//
//  JPIVar.m
//  JSPatchDemo
//
//  Created by liang on 9/19/15.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <objc/runtime.h>

#import "JPEngine.h"
#import "JPIVar.h"

extern NSString *extractStructName(NSString *typeEncodeString);

#define JP_IVAR_GET_SCALAR_CASE(_typeString, _type) \
case _typeString: {                              \
_type value = *(_type *)(base + ivar_getOffset(ivar));   \
returnValue = @(value); \
break; \
}

#define JP_IVAR_GET_STRUCT_CASE(_type, _methodName) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) { \
_type result = *(_type *)(base + ivar_getOffset(ivar));   \
returnValue = [JSValue _methodName:result inContext:[JPEngine context]];    \
break; \
}

#define JP_IVAR_SET_SCALAR_CASE(_typeString, _type, _selector) \
case _typeString: {                              \
_type *pointer = (_type *)(base + ivar_getOffset(ivar));; \
*pointer = [value _selector]; \
break; \
}

#define JP_IVAR_SET_STRUCT_CASE(_type, _methodName) \
if ([typeString rangeOfString:@#_type].location != NSNotFound) { \
_type *pointer = (_type *)(base + ivar_getOffset(ivar));   \
*pointer = [value _methodName];    \
break; \
}


@implementation JPIVar

+ (id)getIvarOfObject:(id)object name:(NSString *)name {
    char *base = (char *)(void *)CFBridgingRetain(object);
    const char *cname = [name cStringUsingEncoding:NSUTF8StringEncoding];
    
    id returnValue = nil;
    Ivar ivar = class_getInstanceVariable([object class], cname);
    if (ivar) {
        const char *returnType = ivar_getTypeEncoding(ivar);
        
        switch (returnType[0]) {
                JP_IVAR_GET_SCALAR_CASE('c', char)
                JP_IVAR_GET_SCALAR_CASE('C', unsigned char)
                JP_IVAR_GET_SCALAR_CASE('s', short)
                JP_IVAR_GET_SCALAR_CASE('S', unsigned short)
                JP_IVAR_GET_SCALAR_CASE('i', int)
                JP_IVAR_GET_SCALAR_CASE('I', unsigned int)
                JP_IVAR_GET_SCALAR_CASE('l', long)
                JP_IVAR_GET_SCALAR_CASE('L', unsigned long)
                JP_IVAR_GET_SCALAR_CASE('q', long long)
                JP_IVAR_GET_SCALAR_CASE('Q', unsigned long long)
                JP_IVAR_GET_SCALAR_CASE('f', float)
                JP_IVAR_GET_SCALAR_CASE('d', double)
                JP_IVAR_GET_SCALAR_CASE('B', BOOL)
            case '{': {
                NSString *typeString = extractStructName([NSString stringWithUTF8String:returnType]);
                
                JP_IVAR_GET_STRUCT_CASE(CGRect, valueWithRect)
                JP_IVAR_GET_STRUCT_CASE(CGPoint, valueWithPoint)
                JP_IVAR_GET_STRUCT_CASE(CGSize, valueWithSize)
                JP_IVAR_GET_STRUCT_CASE(NSRange, valueWithRange)
            }
                
            case '@':
                returnValue = object_getIvar(object, ivar);
                break;
        }
    }
    
    CFBridgingRelease(base);
    return returnValue;
}

+ (void)setIvarOfObject:(id)object name:(NSString *)name value:(id)value {
    char *base = (char *)(__bridge_retained void *)object;
    const char *cname = [name cStringUsingEncoding:NSUTF8StringEncoding];
    
    Ivar ivar = class_getInstanceVariable([object class], cname);
    if (ivar) {
        const char *argumentType = ivar_getTypeEncoding(ivar);
        switch (argumentType[0]) {
                JP_IVAR_SET_SCALAR_CASE('c', char, charValue)
                JP_IVAR_SET_SCALAR_CASE('C', unsigned char, unsignedCharValue)
                JP_IVAR_SET_SCALAR_CASE('s', short, shortValue)
                JP_IVAR_SET_SCALAR_CASE('S', unsigned short, unsignedShortValue)
                JP_IVAR_SET_SCALAR_CASE('i', int, intValue)
                JP_IVAR_SET_SCALAR_CASE('I', unsigned int, unsignedIntValue)
                JP_IVAR_SET_SCALAR_CASE('l', long, longValue)
                JP_IVAR_SET_SCALAR_CASE('L', unsigned long, unsignedLongValue)
                JP_IVAR_SET_SCALAR_CASE('q', long long, longLongValue)
                JP_IVAR_SET_SCALAR_CASE('Q', unsigned long long, unsignedLongLongValue)
                JP_IVAR_SET_SCALAR_CASE('B', BOOL, boolValue)
                JP_IVAR_SET_SCALAR_CASE('f', float, floatValue)
                JP_IVAR_SET_SCALAR_CASE('d', double, doubleValue)
            case '{': {
                NSString *typeString = extractStructName([NSString stringWithUTF8String:argumentType]);
                
                JP_IVAR_SET_STRUCT_CASE(CGRect, toRect)
                JP_IVAR_SET_STRUCT_CASE(CGPoint, toPoint)
                JP_IVAR_SET_STRUCT_CASE(CGSize, toSize)
                JP_IVAR_SET_STRUCT_CASE(NSRange, toRange)
            }
                
            case '@':
                object_setIvar(object, ivar, value);
        }
    }
    
    CFBridgingRelease(base);
}

@end
