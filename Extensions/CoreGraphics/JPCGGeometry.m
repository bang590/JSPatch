//
//  JPCGGeometryHelper.m
//  JSPatchDemo
//
//  Created by Albert438  on 15/7/2.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "JPCGGeometry.h"
#import <CoreGraphics/CGGeometry.h>

@implementation JPCGGeometry

- (void)main:(JSContext *)context
{
    context[@"CGRectContainsPoint"]  = ^BOOL(NSDictionary *rectDict, NSDictionary *pointDict) {
        CGRect rect;
        CGPoint point;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        [JPCGGeometry pointStruct:&point ofDict:pointDict];
        return CGRectContainsPoint(rect, point);
    };

    context[@"CGRectEqualToRect"]    = ^BOOL(NSDictionary *rectDict1, NSDictionary *rectDict2) {
        CGRect rect1,rect2;
        [JPCGGeometry rectStruct:&rect1 ofDict:rectDict1];
        [JPCGGeometry rectStruct:&rect2 ofDict:rectDict2];
        return CGRectEqualToRect(rect1, rect2);
    };

    context[@"CGRectGetMaxX"]        = ^CGFloat(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        return CGRectGetMaxX(rect);
    };

    context[@"CGRectGetMaxY"]        = ^CGFloat(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        return CGRectGetMaxY(rect);
    };

    context[@"CGRectGetMidX"]        = ^CGFloat(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        return CGRectGetMidX(rect);
    };

    context[@"CGRectGetMidY"]        = ^CGFloat(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        return CGRectGetMidY(rect);
    };

    context[@"CGRectGetMinX"]        = ^CGFloat(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        return CGRectGetMinX(rect);
    };

    context[@"CGRectGetMinY"]        = ^CGFloat(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        return CGRectGetMinY(rect);
    };

    context[@"CGRectInset"]          = ^NSDictionary *(NSDictionary *rectDict, CGFloat dx, CGFloat dy) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect rectInset = CGRectInset(rect, dx, dy);
        return [JPCGGeometry rectDictOfStruct:&rectInset];
    };

    context[@"CGRectIntegral"]       = ^NSDictionary *(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect rectIntegral = CGRectIntegral(rect);
        return [JPCGGeometry rectDictOfStruct:&rectIntegral];
    };

    context[@"CGRectIntersection"]   = ^NSDictionary *(NSDictionary *rectDict1, NSDictionary *rectDict2) {
        CGRect rect1,rect2;
        [JPCGGeometry rectStruct:&rect1 ofDict:rectDict1];
        [JPCGGeometry rectStruct:&rect2 ofDict:rectDict2];

    CGRect rectIntersection          = CGRectIntersection(rect1, rect2);
        return [JPCGGeometry rectDictOfStruct:&rectIntersection];
    };

    context[@"CGRectOffset"]         = ^NSDictionary *(NSDictionary *rectDict, CGFloat dx, CGFloat dy) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect rectOffset = CGRectOffset(rect, dx, dy);
        return [JPCGGeometry rectDictOfStruct:&rectOffset];
    };

    context[@"CGRectIntersectsRect"] = ^BOOL(NSDictionary *rectDict1, NSDictionary *rectDict2) {
        CGRect rect1,rect2;
        [JPCGGeometry rectStruct:&rect1 ofDict:rectDict1];
        [JPCGGeometry rectStruct:&rect2 ofDict:rectDict2];
        return CGRectIntersectsRect(rect1, rect2);
    };
}

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


- (size_t)sizeOfStructWithTypeName:(NSString *)typeName
{
    if ([typeName rangeOfString:@"CGVector"].location != NSNotFound) {
        return sizeof(CGVector);
    }
    
    if ([typeName rangeOfString:@"CGRect"].location != NSNotFound) {
        return sizeof(CGRect);
    }
    
    if ([typeName rangeOfString:@"CGPoint"].location != NSNotFound) {
        return sizeof(CGPoint);
    }
    
    if ([typeName rangeOfString:@"CGSize"].location != NSNotFound) {
        return sizeof(CGSize);
    }
    
    return 0;
}

- (NSDictionary *)dictOfStruct:(void *)structData typeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"CGVector"]) {
        CGVector *vector = (CGVector *)structData;
        return [JPCGGeometry vectorDictOfStruct:vector];
    }
    return nil;
}

- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"CGVector"]) {
        [JPCGGeometry vectorStruct:structData ofDict:dict];
    }
}

@end
