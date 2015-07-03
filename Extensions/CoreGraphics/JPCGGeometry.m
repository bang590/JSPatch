//
//  JPCGGeometryHelper.m
//  JSPatchDemo
//
//  Created by Albert438  on 15/7/2.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "JPCGGeometry.h"

@implementation JPCGGeometry

+ (void)rectStruct:(CGRect *)rect ofDict:(NSDictionary *)dict
{
    CGPoint point;
    CGSize size;
    point.x      = [dict[@"x"] doubleValue];
    point.y      = [dict[@"y"] doubleValue];
    size.width   = [dict[@"width"] doubleValue];
    size.height  = [dict[@"height"] doubleValue];
    rect->origin = point;
    rect->size   = size;
    
}

+ (void)pointStruct:(CGPoint *)point ofDict:(NSDictionary *)dict
{
    point->x = [dict[@"x"] doubleValue];
    point->y = [dict[@"y"] doubleValue];
}

+ (void)sizeStruct:(CGSize *)size ofDict:(NSDictionary *)dict
{
    size->width  = [dict[@"width"] doubleValue];
    size->height = [dict[@"height"] doubleValue];
}

+ (void)vectorStruct:(CGVector *)vector ofDict:(NSDictionary *)dict
{
    vector->dx = [dict[@"dx"] doubleValue];
    vector->dy = [dict[@"dy"] doubleValue];
}

+ (NSDictionary *)rectDictOfStruct:(CGRect *)rect
{
    return @{@"x": @(rect->origin.x), @"y": @(rect->origin.y), @"width": @(rect->size.width), @"height": @(rect->size.height)};
}

+ (NSDictionary *)sizeDictOfStruct:(CGSize *)size
{
    return @{@"width": @(size->width), @"height": @(size->height)};
}

+ (NSDictionary *)pointDictOfStruct:(CGPoint *)point
{
    return @{@"x": @(point->x), @"y": @(point->y)};
}

+ (NSDictionary *)vectorDictOfStruct:(CGVector *)vector
{
    return @{@"dx": @(vector->dx), @"dy": @(vector->dy)};
}


- (size_t)sizeOfStructWithTypeEncoding:(NSString *)typeEncoding
{
    if ([typeEncoding rangeOfString:@"CGVector"].location == 1) {
        return sizeof(CGVector);
    }
    return 0;
}

- (NSDictionary *)dictOfStruct:(void *)structData typeEncoding:(NSString *)typeEncoding
{
    if ([typeEncoding rangeOfString:@"CGVector"].location == 1) {
        CGVector *vector = (CGVector *)structData;
        return [JPCGGeometry vectorDictOfStruct:vector];
    }
    return nil;
}

- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeEncoding:(NSString *)typeEncoding
{
    if ([typeEncoding rangeOfString:@"CGVector"].location == 1) {
        [JPCGGeometry vectorStruct:structData ofDict:dict];
    }
}

@end
