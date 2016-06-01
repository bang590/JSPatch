//
//  JPStructPointer.m
//  JSPatchDemo
//
//  Created by bang on 15/8/13.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPStructPointer.h"

@implementation JPStructPointer
+ (void)main:(JSContext *)context
{
    __weak JSContext *weakCtx = context;
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
            NSDictionary *structDefine = [JPExtension registeredStruct][structName];
            if (structDefine) {
                int size = [self sizeOfStructTypes:structDefine[@"types"]];
                void *ret = malloc(size);
                memset(ret, 0, size);
                [self getStructDataWidthDict:ret dict:[structDict toObject] structDefine:structDefine];
                return [self formatPointerOCToJS:ret];
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
            
            JSContext *context = [JPEngine context];
            @synchronized (context) {
                NSDictionary *structDefine = [JPExtension registeredStruct][structName];
                if (structDefine) {
                    return [self getDictOfStruct:[self formatPointerJSToOC:structPointer] structDefine:structDefine];
                }
            }
        }
        return nil;
    };
}
@end
