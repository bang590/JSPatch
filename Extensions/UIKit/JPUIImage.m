//
//  JPUIImage.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPUIImage.h"
#import <UIKit/UIKit.h>

@implementation JPUIImage

+ (void)main:(JSContext *)context
{
    context[@"UIImageJPEGRepresentation"] = ^id(JSValue *jsVal, CGFloat compressionQuality) {
        UIImage *image = [self formatJSToOC:jsVal];
        NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
        return [self formatOCToJS:data];
    };
    
    context[@"UIImagePNGRepresentation"]  = ^id(JSValue *jsVal) {
        UIImage *image = [self formatJSToOC:jsVal];
        NSData *data   =  UIImagePNGRepresentation(image);
        return [self formatOCToJS:data];
    };
    
}

@end
