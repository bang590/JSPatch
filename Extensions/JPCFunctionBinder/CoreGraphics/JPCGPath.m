//
//  JPCGPath.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPCGPath.h"
#import "JPCGTransform.h"
#import "JPCGGeometry.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation JPCGPath

+ (void)main:(JSContext *)context
{
    context[@"CGPathAddArc"]                  = ^void(JSValue *path, NSDictionary *m,
                                       CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle,
                                       bool clockwise) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPathAddArc([self formatPointerJSToOC:path], &transform, x, y, radius, startAngle, endAngle, clockwise);
    };

    context[@"CGPathAddArcToPoint"]           = ^void(JSValue *path,
                                            NSDictionary *m, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2,
                                            CGFloat radius) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPathAddArcToPoint([self formatPointerJSToOC:path], &transform, x1, y1, x2, y2, radius);
    };
    context[@"CGPathAddCurveToPoint"]         = ^void(JSValue *path,
                                              NSDictionary *m, CGFloat cp1x, CGFloat cp1y,
                                              CGFloat cp2x, CGFloat cp2y, CGFloat x, CGFloat y) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPathAddCurveToPoint([self formatPointerJSToOC:path], &transform, cp1x, cp1y, cp2x, cp2y, x, y);
    };

    context[@"CGPathAddEllipseInRect"]        = ^void(JSValue *path,
                                               NSDictionary *m, NSDictionary *rectDict) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGPathAddEllipseInRect([self formatPointerJSToOC:path], &transform, rect);
    };

    context[@"CGPathAddLineToPoint"]          = ^void(JSValue *path,
                                             NSDictionary *m, CGFloat x, CGFloat y) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPathAddLineToPoint([self formatPointerJSToOC:path], &transform, x, y);
    };


    context[@"CGPathAddLines"]                = ^void(JSValue *path,
                                      NSDictionary *m, NSArray *pointsArray, size_t count) {
        CGPoint *points = malloc(sizeof(CGPoint) * count);
        for (int i = 0; i < count; i++) {
            CGPoint point;
            [JPCGGeometry pointStruct:&point ofDict:pointsArray[i]];
            points[i]   = point;
        }
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPathAddLines([self formatPointerJSToOC:path], &transform, points, count);
        free(points);
    };

    context[@"CGPathAddRect"]                 = ^void(JSValue *path, NSDictionary *m,
                                      NSDictionary *rectDict) {
        CGRect rect;
        CGAffineTransform transform;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPathAddRect([self formatPointerJSToOC:path], &transform, rect);
    };

    context[@"CGPathCreateMutable"]           = ^id() {
        CGMutablePathRef path = CGPathCreateMutable();
        return [self formatRetainedCFTypeOCToJS:path];
    };

    context[@"CGPathMoveToPoint"]             = ^void(JSValue *path,
                                               NSDictionary *m, CGFloat x, CGFloat y) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPathMoveToPoint([self formatPointerJSToOC:path], &transform, x, y);
    };

    context[@"CGPathCloseSubpath"]            = ^void(JSValue *path) {
        CGPathCloseSubpath([self formatPointerJSToOC:path]);
    };

    context[@"CGPathContainsPoint"]           = ^BOOL(JSValue *path,
                                               NSDictionary *m, NSDictionary *pointDict, bool eoFill) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:m];
        CGPoint point;
        [JPCGGeometry pointDictOfStruct:&point];
        return CGPathContainsPoint([self formatPointerJSToOC:path], &transform, point, eoFill);
    };

    context[@"CGPathCreateWithEllipseInRect"] = ^id(NSDictionary *rectDict,
                                                    NSDictionary *transformDict) {
        CGRect rect;
        CGAffineTransform transform;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        [JPCGTransform transStruct:&transform ofDict:transformDict];
        CGPathRef path = CGPathCreateWithEllipseInRect(rect, &transform);
        return [self formatRetainedCFTypeOCToJS:(void *)path];
    };

    context[@"CGPathGetPathBoundingBox"]      = ^NSDictionary *(JSValue *path) {
        CGRect rect = CGPathGetPathBoundingBox([self formatPointerJSToOC:path]);
        return [JPCGGeometry rectDictOfStruct:&rect];
    };

    context[@"CGPathRelease"]                 = ^void(JSValue *path) {
        CGPathRelease([self formatPointerJSToOC:path]);
    };
}


@end
