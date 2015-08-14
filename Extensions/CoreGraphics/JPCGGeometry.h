//
//  JPCGGeometryHelper.h
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/2.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "JPEngine.h"

@interface JPCGGeometry : JPExtension

+ (void)rectStruct:(CGRect *)rect ofDict:(NSDictionary *)dict;

+ (void)pointStruct:(CGPoint *)point ofDict:(NSDictionary *)dict;

+ (void)sizeStruct:(CGSize *)size ofDict:(NSDictionary *)dict;

+ (void)vectorStruct:(CGVector *)vector ofDict:(NSDictionary *)dict;

+ (NSDictionary *)rectDictOfStruct:(CGRect *)rect;

+ (NSDictionary *)sizeDictOfStruct:(CGSize *)size;

+ (NSDictionary *)pointDictOfStruct:(CGPoint *)point;

+ (NSDictionary *)vectorDictOfStruct:(CGVector *)vector;
@end
