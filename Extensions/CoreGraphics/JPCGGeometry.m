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

+ (void)main:(JSContext *)context
{
    [JPEngine defineStruct:@{
                             @"name": @"CGVector",
                             @"types": @"FF",
                             @"keys": @[@"dx", @"dy"]
                             }];
    
    [JPEngine defineStruct:@{
                             @"name": @"CGAffineTransform",
                             @"types": @"FFFFFF",
                             @"keys": @[@"a", @"b", @"c", @"d", @"tx", @"ty"]
                             }];
    
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

    context[@"CGRectInset"]          = ^CGRect(NSDictionary *rectDict, CGFloat dx, CGFloat dy) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect rectInset = CGRectInset(rect, dx, dy);
        return rectInset;
    };

    context[@"CGRectIntegral"]       = ^CGRect(NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect rectIntegral = CGRectIntegral(rect);
        return rectIntegral;
    };

    context[@"CGRectIntersection"]   = ^CGRect(NSDictionary *rectDict1, NSDictionary *rectDict2) {
        CGRect rect1,rect2;
        [JPCGGeometry rectStruct:&rect1 ofDict:rectDict1];
        [JPCGGeometry rectStruct:&rect2 ofDict:rectDict2];

        CGRect rectIntersection = CGRectIntersection(rect1, rect2);
        return rectIntersection;
    };

    context[@"CGRectOffset"]         = ^CGRect(NSDictionary *rectDict, CGFloat dx, CGFloat dy) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect rectOffset = CGRectOffset(rect, dx, dy);
        return rectOffset;
    };

    context[@"CGRectIntersectsRect"] = ^BOOL(NSDictionary *rectDict1, NSDictionary *rectDict2) {
        CGRect rect1,rect2;
        [JPCGGeometry rectStruct:&rect1 ofDict:rectDict1];
        [JPCGGeometry rectStruct:&rect2 ofDict:rectDict2];
        return CGRectIntersectsRect(rect1, rect2);
    };
}

#if CGFLOAT_IS_DOUBLE
#define CGFloatValue doubleValue
#else
#define CGFloatValue floatValue
#endif

+ (void)rectStruct:(CGRect *)rect ofDict:(NSDictionary *)dict
{
    CGPoint point;
    CGSize size;
    point.x      = [dict[@"x"] CGFloatValue];
    point.y      = [dict[@"y"] CGFloatValue];
    size.width   = [dict[@"width"] CGFloatValue];
    size.height  = [dict[@"height"] CGFloatValue];
    rect->origin = point;
    rect->size   = size;
    
}

+ (void)pointStruct:(CGPoint *)point ofDict:(NSDictionary *)dict
{
    point->x = [dict[@"x"] CGFloatValue];
    point->y = [dict[@"y"] CGFloatValue];
}

+ (void)sizeStruct:(CGSize *)size ofDict:(NSDictionary *)dict
{
    size->width  = [dict[@"width"] CGFloatValue];
    size->height = [dict[@"height"] CGFloatValue];
}

+ (void)vectorStruct:(CGVector *)vector ofDict:(NSDictionary *)dict
{
    vector->dx = [dict[@"dx"] CGFloatValue];
    vector->dy = [dict[@"dy"] CGFloatValue];
}

#undef CGFloatValue

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
@end
