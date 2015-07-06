//
//  JPUIGeometry.h
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPEngine.h"
#import "JPUIKitHeader.h"

@interface JPUIGeometry : JPExtension

+ (void)edgeInsetsStruct:(UIEdgeInsets *)edgeInsets ofDict:(NSDictionary *)dict;

+ (NSDictionary *)edgeInsetOfStruct:(UIEdgeInsets *)edgeInsets;

@end
