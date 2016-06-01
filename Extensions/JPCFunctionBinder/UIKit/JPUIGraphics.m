//
//  UIGraphics.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//


#import "JPUIGraphics.h"
#import "JPCGGeometry.h"
#import <UIKit/UIKit.h>

@implementation JPUIGraphics

+ (void)main:(JSContext *)context
{
    context[@"UIGraphicsGetCurrentContext"] = ^id() {
        CGContextRef c = UIGraphicsGetCurrentContext();
        return [self formatPointerOCToJS:c];
    };
    
    context[@"UIGraphicsBeginImageContext"] = ^void(NSDictionary *sizeDict) {
        CGSize size;
        [JPCGGeometry sizeStruct:&size ofDict:sizeDict];
        UIGraphicsBeginImageContext(size);
    };
    
    context[@"UIGraphicsBeginImageContextWithOptions"] = ^void(NSDictionary *sizeDict, BOOL opaque, CGFloat scale) {
        CGSize size;
        [JPCGGeometry sizeStruct:&size ofDict:sizeDict];
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    };
    
    context[@"UIGraphicsGetImageFromCurrentImageContext"] = ^id() {
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        return [self formatOCToJS:image];
    };
    
    context[@"UIGraphicsEndImageContext"] = ^void() {
        UIGraphicsEndImageContext();
    };
}

@end
