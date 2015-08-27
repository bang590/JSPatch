//
//  JPCGTransform.h
//  JSPatchDemo
//
//  Created by bang on 15/6/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPEngine.h"
#import <CoreGraphics/CoreGraphics.h>

@interface JPCGTransform : JPExtension

+ (NSDictionary *)transDictOfStruct:(CGAffineTransform *)trans;
+ (void)transStruct:(CGAffineTransform *)trans ofDict:(NSDictionary *)dict;

@end
