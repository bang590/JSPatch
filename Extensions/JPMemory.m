//
//  JPMemory.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPMemory.h"

@implementation JPMemory

- (void)main:(JSContext *)context
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
            for (JPExtension *ext in registeredStructExtensions) {
                size_t size = [ext sizeOfStructWithTypeName:typeName];
                if (size) {
                    return size;
                }
            }
        }
        return 0;
    };
    
    context[@"newStruct"] = ^id(NSString *structName, JSValue *structDict) {
        #define JP_NEW_STRUCT(_type, _method) \
            if ([structName isEqualToString:@#_type]) {   \
                void *ret = malloc(sizeof(_type)); \
                _type rect = [structDict _method];  \
                ret = memcpy(ret, &rect, sizeof(_type));   \
                return [self formatPointerOCToJS:ret];  \
            }
        JP_NEW_STRUCT(CGRect, toRect)
        JP_NEW_STRUCT(CGPoint, toPoint)
        JP_NEW_STRUCT(CGSize, toSize)
        JP_NEW_STRUCT(NSRange, toRange)
        
        @synchronized (weakCtx) {
            for (JPExtension *ext in registeredStructExtensions) {
                size_t size = [ext sizeOfStructWithTypeName:structName];
                if (size) {
                    void *ret = malloc(size);
                    [ext structData:ret ofDict:[structDict toObject] typeName:structName];
                    return [self formatPointerOCToJS:ret];
                }
            }
        }
        return nil;
    };
    
    context[@"pvalStruct"] = ^id(NSString *structName, JSValue *structPointer) {
        if ([structName isEqualToString:@"CGRect"]) {
            CGRect *rect = [self formatPointerJSToOC:structPointer];
            return @{@"x": @(rect->origin.x), @"y": @(rect->origin.y), @"width": @(rect->size.width), @"height": @(rect->size.height)};
        }
        if ([structName isEqualToString:@"CGPoint"]) {
            CGPoint *point = [self formatPointerJSToOC:structPointer];
            return @{@"x": @(point->x), @"y": @(point->y)};
        }
        if ([structName isEqualToString:@"CGSize"]) {
            CGSize *size = [self formatPointerJSToOC:structPointer];
            return @{@"width": @(size->width), @"height": @(size->height)};
        }
        if ([structName isEqualToString:@"NSRange"]) {
            NSRange *range = [self formatPointerJSToOC:structPointer];
            return @{@"location": @(range->location), @"length": @(range->length)};
        }
        @synchronized (weakCtx) {
            for (JPExtension *ext in registeredStructExtensions) {
                NSDictionary *dict = [ext dictOfStruct:[self formatPointerJSToOC:structPointer] typeName:structName];
                if (dict) return dict;
            }
        }
        return nil;
    };
}

@end
