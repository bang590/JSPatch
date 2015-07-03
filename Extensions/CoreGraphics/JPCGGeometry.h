//
//  JPCGGeometryHelper.h
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/2.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "JPEngine.h"
#import <CoreGraphics/CoreGraphics.h>

@interface JPCGGeometry : JPExtension

+ (void)transCGRectStruct:(CGRect *)rect ofDict:(NSDictionary *)dict;

+ (void)transCGPointStruct:(CGPoint *)point ofDict:(NSDictionary *)dict;

+ (void)transCGSizeStruct:(CGSize *)size ofDict:(NSDictionary *)dict;

+ (void)transCGVectorStruct:(CGVector *)vector ofDict:(NSDictionary *)dict;

+ (NSDictionary *)transCGRectDictOfStruct:(CGRect *)rect;

+ (NSDictionary *)transCGSizeDictOfStruct:(CGSize *)size;

+ (NSDictionary *)transCGPointDictOfStruct:(CGPoint *)point;

+ (NSDictionary *)transCGVectorDictOfStruct:(CGVector *)vector;

@end
