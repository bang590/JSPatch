//
//  JPCGContext.m
//
//
//  Created by Albert438 on 15/7/2.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "JPCGContext.h"
#import "JPCGTransform.h"
#import "JPCGGeometry.h"
#import <UIKit/UIKit.h>

@implementation JPCGContext

+ (void)main:(JSContext *)context
{
    context[@"CGContextSetLineCap"]            = ^void(JSValue *c, int cap) {
        CGContextSetLineCap([self formatPointerJSToOC:c], cap);
    };
    
    context[@"CGContextSetFillColorWithColor"] = ^void(JSValue *c, JSValue *color) {
        CGContextSetFillColorWithColor([self formatPointerJSToOC:c], [self formatPointerJSToOC:color]);
    };
    
    context[@"CGContextSetLineWidth"]          = ^void(JSValue *c, CGFloat lineWidthValue) {
        CGContextSetLineWidth([self formatPointerJSToOC:c], lineWidthValue);
    };
    
    context[@"CGContextBeginPath"]             = ^void(JSValue *c) {
        CGContextBeginPath([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextMoveToPoint"]           = ^void(JSValue *c, CGFloat x, CGFloat y) {
        CGContextMoveToPoint([self formatPointerJSToOC:c], x, y);
    };
    
    context[@"CGContextAddLineToPoint"]        = ^void(JSValue *c, CGFloat x, CGFloat y) {
        CGContextAddLineToPoint([self formatPointerJSToOC:c], x, y);
    };
    
    context[@"CGContextStrokePath"]            = ^void(JSValue *c) {
        CGContextStrokePath([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextSetRGBStrokeColor"]     = ^void(JSValue *c,CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha){
        CGContextSetRGBStrokeColor([self formatPointerJSToOC:c], red, green, blue, alpha);
    };
    
    context[@"CGContextSetRGBFillColor"]       = ^void(JSValue *c,CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha){
        CGContextSetRGBFillColor([self formatPointerJSToOC:c], red, green, blue, alpha);
    };
    
    context[@"CGContextClosePath"]             = ^void(JSValue *c) {
        CGContextClosePath([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextStrokeRect"]            = ^void(JSValue *c, NSDictionary *cgRectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:cgRectDict];
        CGContextStrokeRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextAddArc"]                = ^void(JSValue *c, CGFloat x, CGFloat y,
                                                       CGFloat radius, CGFloat startAngle, CGFloat endAngle, int clockwise) {
        CGContextAddArc([self formatPointerJSToOC:c], x, y, radius, startAngle, endAngle, clockwise);
    };
    
    context[@"CGContextAddArcToPoint"]         = ^void(JSValue *c, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, CGFloat radius) {
        CGContextAddArcToPoint([self formatPointerJSToOC:c], x1, y1, x2, y2, radius);
    };
    
    context[@"CGContextAddRect"]               = ^void(JSValue *c, NSDictionary *cgRectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:cgRectDict];
        CGContextAddRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextAddPath"]               = ^void(JSValue *c, JSValue *path) {
        CGContextAddPath([self formatPointerJSToOC:c], [self formatPointerJSToOC:path]);
    };
    
    context[@"CGContextAddLines"]              = ^void(JSValue *c, NSArray *points, NSUInteger count){
        CGPoint *pointsArray = malloc(count * sizeof(CGPoint));
        for (int i = 0; i < count; i++) {
            CGPoint point;
            [JPCGGeometry pointStruct:&point ofDict:points[i]];
            pointsArray[i]   = point;
        }
        CGContextAddLines([self formatPointerJSToOC:c], pointsArray, count);
        free(pointsArray);
    };
    
    context[@"CGContextAddEllipseInRect"]      = ^void(JSValue *c, NSDictionary *rectDict){
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextAddEllipseInRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextDrawImage"]             = ^void(JSValue *c, NSDictionary *rectDict, JSValue *image) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextDrawImage([self formatPointerJSToOC:c], rect, [self formatPointerJSToOC:image]);
    };
    
    context[@"CGContextDrawPath"]              = ^void(JSValue *c, int mode) {
        CGContextDrawPath([self formatPointerJSToOC:c], mode);
    };
    
    context[@"CGContextRestoreGState"]         = ^void(JSValue *c) {
        CGContextRestoreGState([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextSaveGState"]            = ^void(JSValue *c) {
        CGContextSaveGState([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextRetain"]                = ^id(JSValue *c) {
        CGContextRef retainContext = CGContextRetain([self formatPointerJSToOC:c]);
        return [self formatPointerOCToJS:retainContext];
    };
    
    context[@"CGContextRelease"]               = ^void(JSValue *c) {
        CGContextRelease([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextTranslateCTM"]          = ^void(JSValue *c, CGFloat tx, CGFloat ty) {
        CGContextTranslateCTM([self formatPointerJSToOC:c], tx, ty);
    };
    
    context[@"CGContextScaleCTM"]              = ^void(JSValue *c, CGFloat sx, CGFloat sy) {
        CGContextScaleCTM([self formatPointerJSToOC:c], sx, sy);
    };
    
    context[@"CGContextFillPath"]              = ^void(JSValue *c) {
        CGContextFillPath([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextFillRect"]              = ^void(JSValue *c, NSDictionary *cgRectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:cgRectDict];
        CGContextFillRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextSetShadowWithColor"]    = ^void(JSValue *c, CGSize offset, CGFloat blur, JSValue *color) {
        CGContextSetShadowWithColor([self formatPointerJSToOC:c], offset, blur, [self formatPointerJSToOC:color]);
    };
    
    context[@"CGContextClip"]                  = ^void(JSValue *c) {
        CGContextClip([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextConcatCTM"]             = ^void(JSValue *c, NSDictionary *transfromDict) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:transfromDict];
        CGContextConcatCTM([self formatPointerJSToOC:c], transform);
    };
    
    context[@"CGContextGetClipBoundingBox"]    = ^void(JSValue *c) {
        CGContextGetClipBoundingBox([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextClearRect"]             = ^void(JSValue *c, NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextClearRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextFillEllipseInRect"]     = ^void(JSValue *c, NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextFillEllipseInRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextDrawLinearGradient"]    = ^void(JSValue *c,JSValue *gradient, NSDictionary *startPointDict, NSDictionary *endPointDict,int options) {
        CGPoint startPoint;
        CGPoint endPoint;
        [JPCGGeometry pointStruct:&startPoint ofDict:startPointDict];
        [JPCGGeometry pointStruct:&endPoint ofDict:endPointDict];
        CGContextDrawLinearGradient([self formatPointerJSToOC:c], [self formatPointerJSToOC:gradient], startPoint, endPoint, options);
    };
    
    context[@"CGContextSetAlpha"]              = ^void(JSValue *c, CGFloat a) {
        CGContextSetAlpha([self formatPointerJSToOC:c], a);
    };
    
    context[@"CGContextClipToRect"]            = ^void(JSValue *c, NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextClipToRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextSetInterpolationQuality"] = ^void(JSValue *c, int quality) {
        CGContextSetInterpolationQuality([self formatPointerJSToOC:c], quality);
    };
    
    context[@"CGContextClipToMask"]              = ^void(JSValue *c, NSDictionary *rectDict, JSValue *mask) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextClipToMask([self formatPointerJSToOC:c], rect, [self formatPointerJSToOC:mask]);
    };
    
    context[@"CGContextSetTextDrawingMode"]      = ^void(JSValue *c, int mode) {
        CGContextSetTextDrawingMode([self formatPointerJSToOC:c], mode);
    };
    
    context[@"CGContextGetCTM"]                  = ^void(JSValue *c) {
        CGContextGetCTM([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextStrokeEllipseInRect"]     = ^void(JSValue *c, NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextStrokeEllipseInRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextSetLineDash"]             = ^void(JSValue *c, CGFloat phase,
                                                         NSArray *lengths, size_t count) {
        CGFloat *lengthsArray = malloc(count * sizeof(CGFloat));
        for (int i = 0 ; i < count; i++) {
            lengthsArray[i] = [lengths[i] doubleValue];
        }
        CGContextSetLineDash([self formatPointerJSToOC:c], phase, lengthsArray, count);
        free(lengthsArray);
    };
    
    context[@"CGContextRotateCTM"]               = ^void(JSValue *c, CGFloat angle) {
        CGContextRotateCTM([self formatPointerJSToOC:c], angle);
    };
    
    context[@"CGContextSetLineJoin"]             = ^void(JSValue *c, int join) {
        CGContextSetLineJoin([self formatPointerJSToOC:c], join);
    };
    
    context[@"CGContextSetGrayFillColor"]        = ^void(JSValue *c, CGFloat gray,
                                                         CGFloat alpha) {
        CGContextSetGrayFillColor([self formatPointerJSToOC:c], gray, alpha);
    };
    
    context[@"CGContextBeginTransparencyLayer"]  = ^void(JSValue *c,JSValue *auxiliaryInfo) {
        CGContextBeginTransparencyLayer([self formatPointerJSToOC:c], [self formatPointerJSToOC:auxiliaryInfo]);
    };
    
    context[@"CGContextSetBlendMode"]            = ^void(JSValue *context, int mode) {
        CGContextSetBlendMode([self formatPointerJSToOC:context], mode);
    };
    
    context[@"CGContextEndTransparencyLayer"]    = ^void(JSValue *c) {
        CGContextEndTransparencyLayer([self formatPointerJSToOC:c]);
    };
    
    context[@"CGContextSetShadow"]               = ^void(JSValue *c, NSDictionary *offsetDict,
                                                         CGFloat blur) {
        CGSize size;
        [JPCGGeometry sizeStruct:&size ofDict:offsetDict];
        CGContextSetShadow([self formatPointerJSToOC:c], size, blur);
    };
    
    context[@"CGContextSetTextMatrix"]           = ^void(JSValue *c, NSDictionary *transformDict) {
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:transformDict];
        CGContextSetTextMatrix([self formatPointerJSToOC:c], transform);
    };
    
    context[@"CGContextSetTextPosition"]         = ^(JSValue *c, CGFloat x, CGFloat y) {
        CGContextSetTextPosition([self formatPointerJSToOC:c], x, y);
    };
    
    context[@"CGContextSetMiterLimit"]           = ^(JSValue *c, CGFloat limit) {
        CGContextSetMiterLimit([self formatPointerJSToOC:c], limit);
    };
    
    context[@"CGContextStrokeRect"]              = ^(JSValue *c, NSDictionary *rectDict) {
        CGRect rect;
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGContextStrokeRect([self formatPointerJSToOC:c], rect);
    };
    
    context[@"CGContextSetFillColorSpace"]       = ^(JSValue *c, JSValue *space) {
        CGContextSetFillColorSpace([self formatPointerJSToOC:c], [self formatPointerJSToOC:space]);
    };
    
    context[@"CGContextSetFlatness"]             = ^(JSValue *c, CGFloat flatness) {
        CGContextSetFlatness([self formatPointerJSToOC:c], flatness);
    };
}

@end
