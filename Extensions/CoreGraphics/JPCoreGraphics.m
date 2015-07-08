//
//  JPCoreGraphics.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/3.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "JPCoreGraphics.h"
#import "JPEngine.h"


@implementation JPCoreGraphics

- (void)main:(JSContext *)context
{
    NSArray *extensionArray = @[[JPCGTransform instance],[JPCGContext instance],
                                            [JPCGGeometry instance],[JPCGBitmapContext instance],
                                            [JPCGColor instance],[JPCGImage instance],[JPCGPath instance]];
    [JPEngine addExtensions:extensionArray];
}

@end
