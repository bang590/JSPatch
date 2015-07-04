//
//  JPCGImage.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/3.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPCGImage.h"
#import "JPCoreGraphicsHeader.h"
#import <CoreGraphics/CGImage.h>

@implementation JPCGImage

- (void)main:(JSContext *)context
{
    context[@"CGImageCreate"] = ^id(size_t width, size_t height,
                                    size_t bitsPerComponent, size_t bitsPerPixel, size_t bytesPerRow,
                                    JSValue *space, int bitmapInfo, JSValue *provider,
                                    NSArray *decodeArray, bool shouldInterpolate,
                                    int intent) {
        if (decodeArray == nil) {
            CGImageRef  createdImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel,bytesPerRow, [self formatPointerJSToOC:space], bitmapInfo, [self formatPointerJSToOC:provider], NULL, shouldInterpolate, intent);
            return [self formatPointerOCToJS:createdImage];
        }else {
            CGFloat *decode = malloc(decodeArray.count * sizeof(CGFloat));
            for (int i = 0; i < decodeArray.count; i++) {
                decode[i] = [decodeArray[i] doubleValue];
            }
            CGImageRef  createdImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel,bytesPerRow, [self formatPointerJSToOC:space], bitmapInfo, [self formatPointerJSToOC:provider], decode, shouldInterpolate, intent);
            return [self formatPointerOCToJS:createdImage];
        }
    };
    
    context[@"CGImageCreateWithImageInRect"] = ^id(JSValue *image, NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGImageRef retImage = CGImageCreateWithImageInRect([self formatPointerJSToOC:image], rect);
        return [self formatPointerOCToJS:retImage];
    };
    
    context[@"CGImageCreateWithMask"]        = ^id(JSValue *image, JSValue *mask) {
        CGImageRef createdImage = CGImageCreateWithMask([self formatPointerJSToOC:image], [self formatPointerJSToOC:mask]);
        return [self formatPointerOCToJS:createdImage];
    };
    
    context[@"CGImageGetAlphaInfo"]          = ^CGImageAlphaInfo(JSValue *image) {
        return CGImageGetAlphaInfo([self formatPointerJSToOC:image]);
    };
    
    context[@"CGImageGetBitmapInfo"]         = ^CGBitmapInfo(JSValue *image) {
        CGBitmapInfo ret =  CGImageGetBitmapInfo([self formatPointerJSToOC:image]);
        return ret;
    };
    
    context[@"test"] = ^void(JSValue *val) {
        id b = [self formatJSToOC:val];
        if (b == nil) {
            NSLog(@"nil");
        }
    };
}

//"_CGImageGetAlphaInfo" = 1;
//"_CGImageGetBitmapInfo" = 2;
//"_CGImageGetBitsPerComponent" = 2;
//"_CGImageGetColorSpace" = 3;
//"_CGImageGetDataProvider" = 1;
//"_CGImageGetHeight" = 15;
//"_CGImageGetWidth" = 15;
//"_CGImageRelease" = 51;
//"_CGImageSourceCopyPropertiesAtIndex" = 4;
//"_CGImageSourceCreateThumbnailAtIndex" = 1;
//"_CGImageSourceCreateWithData" = 3;
//"_CGImageSourceCreateWithURL" = 2;

@end
