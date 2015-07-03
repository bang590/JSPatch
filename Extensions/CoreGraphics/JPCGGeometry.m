//
//  JPCGGeometryHelper.m
//  JSPatchDemo
//
//  Created by Albert438  on 15/7/2.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "JPCGGeometry.h"

@implementation JPCGGeometry

+ (void)transCGRectStruct:(CGRect *)rect ofDict:(NSDictionary *)dict
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

+ (void)transCGPointStruct:(CGPoint *)point ofDict:(NSDictionary *)dict
{
    point->x = [dict[@"x"] doubleValue];
    point->y = [dict[@"y"] doubleValue];
}

+ (void)transCGSizeStruct:(CGSize *)size ofDict:(NSDictionary *)dict
{
    size->width  = [dict[@"width"] doubleValue];
    size->height = [dict[@"height"] doubleValue];
}

+ (void)transCGVectorStruct:(CGVector *)vector ofDict:(NSDictionary *)dict
{
    vector->dx = [dict[@"dx"] doubleValue];
    vector->dy = [dict[@"dy"] doubleValue];
}

+ (NSDictionary *)transCGRectDictOfStruct:(CGRect *)rect
{
    return @{@"x": @(rect->origin.x), @"y": @(rect->origin.y), @"width": @(rect->size.width), @"height": @(rect->size.height)};
}

+ (NSDictionary *)transCGSizeDictOfStruct:(CGSize *)size
{
    return @{@"width": @(size->width), @"height": @(size->height)};
}

+ (NSDictionary *)transCGPointDictOfStruct:(CGPoint *)point
{
    return @{@"x": @(point->x), @"y": @(point->y)};
}

+ (NSDictionary *)transCGVectorDictOfStruct:(CGVector *)vector
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
        return [JPCGGeometry transCGVectorDictOfStruct:vector];
    }
    return nil;
}

- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeEncoding:(NSString *)typeEncoding
{
    if ([typeEncoding rangeOfString:@"CGVector"].location == 1) {
        [JPCGGeometry transCGVectorStruct:structData ofDict:dict];
    }
}

@end
