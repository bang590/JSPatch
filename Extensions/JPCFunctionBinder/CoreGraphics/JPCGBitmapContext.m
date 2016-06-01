//
//  JPCGBitmapContext.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/3.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPCGBitmapContext.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation JPCGBitmapContext

+ (void)main:(JSContext *)context
{
    context[@"CGBitmapContextCreate"]         = ^id(JSValue *data, size_t width,
                                                    size_t height, size_t bitsPerComponent, size_t bytesPerRow,
                                                    JSValue *space, uint32_t bitmapInfo) {
        CGContextRef bitmapContext = CGBitmapContextCreate([self formatPointerJSToOC:data], width, height, bitsPerComponent, bytesPerRow, [self formatPointerJSToOC:space], bitmapInfo);
        return [self formatRetainedCFTypeOCToJS:bitmapContext];
    };
    
    context[@"CGBitmapContextCreateImage"]    = ^id(JSValue *c) {
        CGImageRef image = CGBitmapContextCreateImage([self formatPointerJSToOC:c]);
        return [self formatRetainedCFTypeOCToJS:image];
    };
    
    context[@"CGBitmapContextGetBytesPerRow"] = ^size_t(JSValue *c) {
        return CGBitmapContextGetBytesPerRow([self formatPointerJSToOC:c]);
    };
    
    context[@"CGBitmapContextGetData"]        = ^id(JSValue *c) {
        return [self formatPointerJSToOC:CGBitmapContextGetData([self formatPointerJSToOC:c])];
    };
    
    context[@"CGBitmapContextGetHeight"]      = ^size_t(JSValue *c) {
        return CGBitmapContextGetHeight([self formatPointerJSToOC:c]);
    };
    
    context[@"CGBitmapContextGetWidth"]       = ^size_t(JSValue *c) {
        return CGBitmapContextGetWidth([self formatPointerJSToOC:c]);
    };
    
    context[@"CGImageRelease"]                = ^void(JSValue *image) {
        CGImageRelease([self formatPointerJSToOC:image]);
    };
}

@end
