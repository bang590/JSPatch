//
//  JPUIKit.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPUIKit.h"
#import "JPUIKitHeader.h"

@implementation JPUIKit

- (void)main:(JSContext *)context
{
    NSArray *extensionArray = @[[JPUIGraphics instance],[JPUIGeometry instance],[JPUIImage instance]];
    [JPEngine addExtensions:extensionArray];
}

@end
