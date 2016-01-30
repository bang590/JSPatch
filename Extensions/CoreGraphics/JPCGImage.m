//
//  JPCGImage.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/3.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPCGImage.h"
#import <CoreGraphics/CoreGraphics.h>
#import "JPCGGeometry.h"

@implementation JPCGImage

+ (void)main:(JSContext *)context
{
    context[@"CGImageCreate"]                = ^id(size_t width, size_t height,
                                                   size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow,
                                                   JSValue *space, int bitmapInfo, JSValue *provider,
                                                   NSArray *decodeArray, bool shouldInterpolate,
                                                   int intent) {
        if (decodeArray == nil) {
            CGImageRef  createdImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel,bytesPerRow, [self formatPointerJSToOC:space], bitmapInfo, [self formatPointerJSToOC:provider], NULL, shouldInterpolate, intent);
            return [self formatRetainedCFTypeOCToJS:createdImage];
        }else {
            CGFloat *decode = malloc(decodeArray.count * sizeof(CGFloat));
            for (int i = 0; i < decodeArray.count; i++) {
                decode[i] = [decodeArray[i] doubleValue];
            }
            CGImageRef  createdImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel,bytesPerRow, [self formatPointerJSToOC:space], bitmapInfo, [self formatPointerJSToOC:provider], decode, shouldInterpolate, intent);
            free(decode);
            return [self formatRetainedCFTypeOCToJS:createdImage];
        }
    };
    
    context[@"CGImageCreateWithImageInRect"] = ^id(JSValue *image, NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGImageRef retImage = CGImageCreateWithImageInRect([self formatPointerJSToOC:image], rect);
        return [self formatRetainedCFTypeOCToJS:retImage];
    };
    
    context[@"CGImageCreateWithMask"]        = ^id(JSValue *image, JSValue *mask) {
        CGImageRef createdImage = CGImageCreateWithMask([self formatPointerJSToOC:image], [self formatPointerJSToOC:mask]);
        return [self formatRetainedCFTypeOCToJS:createdImage];
    };
    
    context[@"CGImageGetAlphaInfo"]          = ^CGImageAlphaInfo(JSValue *image) {
        return CGImageGetAlphaInfo([self formatPointerJSToOC:image]);
    };
    
    context[@"CGImageGetBitmapInfo"]         = ^CGBitmapInfo(JSValue *image) {
        CGBitmapInfo ret =  CGImageGetBitmapInfo([self formatPointerJSToOC:image]);
        return ret;
    };
    
    context[@"CGImageGetBitsPerComponent"]   = ^size_t(JSValue *image) {
        return CGImageGetBitsPerComponent([self formatPointerJSToOC:image]);
    };
    
    context[@"CGImageGetColorSpace"]         = ^id(JSValue *image) {
        CGColorSpaceRef space = CGImageGetColorSpace([self formatPointerJSToOC:image]);
        return [self formatPointerOCToJS:space];
    };
    
    context[@"CGImageGetDataProvider"]       = ^id(JSValue *image) {
        CGDataProviderRef provider = CGImageGetDataProvider([self formatPointerJSToOC:image]);
        return [self formatPointerOCToJS:provider];
    };
    
    context[@"CGImageGetHeight"]             = ^size_t(JSValue *image) {
        return CGImageGetHeight([self formatPointerJSToOC:image]);
    };
    
    context[@"CGImageGetWidth"]              = ^size_t(JSValue *image) {
        return CGImageGetWidth([self formatPointerJSToOC:image]);
    };
    
    context[@"CGImageRelease"]               = ^void(JSValue *image) {
        CGImageRelease([self formatPointerJSToOC:image]);
    };
}


@end
