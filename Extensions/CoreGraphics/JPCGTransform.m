//
//  JPCGTransform.m
//  JSPatchDemo
//
//  Created by bang on 15/6/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPCGTransform.h"
#import "JPCGGeometry.h"

#define TRANSFORM_DEFINE @{ \
    @"name": @"CGAffineTransform",  \
    @"types": @"FFFFFF",    \
    @"keys": @[@"a", @"b", @"c", @"d", @"tx", @"ty"]    \
}

@implementation JPCGTransform
static NSDictionary *transformStructDefine;
+ (void)main:(JSContext *)context
{
    transformStructDefine = TRANSFORM_DEFINE;
    [JPEngine defineStruct:transformStructDefine];
    
    context[@"CGAffineTransformMakeTranslation"] = ^id(CGFloat tx, CGFloat ty) {
    CGAffineTransform trans                      = CGAffineTransformMakeTranslation(tx, ty);
        return [self getDictOfStruct:&trans structDefine:transformStructDefine];
    };

    context[@"CGAffineTransformMakeRotation"]    = ^id(CGFloat angle) {
        CGAffineTransform trans = CGAffineTransformMakeRotation(angle);
        return [self getDictOfStruct:&trans structDefine:transformStructDefine];
    };

    context[@"CGAffineTransformMakeScale"]       = ^id(CGFloat sx, CGFloat sy) {
        CGAffineTransform trans = CGAffineTransformMakeScale(sx, sy);
        return [self getDictOfStruct:&trans structDefine:transformStructDefine];
    };
    
    context[@"CGAffineTransformTranslate"]       = ^id(NSDictionary *transformDict, CGFloat tx, CGFloat ty) {
        CGAffineTransform trans;
        [self getStructDataWidthDict:&trans dict:transformDict structDefine:transformStructDefine];
        CGAffineTransform translatedTransform = CGAffineTransformTranslate(trans, tx, ty);
        return [self getDictOfStruct:&translatedTransform structDefine:transformStructDefine];
    };

    context[@"CGAffineTransformScale"]           = ^id(NSDictionary *transformDict, CGFloat sx, CGFloat sy) {
        CGAffineTransform trans;
        [self getStructDataWidthDict:&trans dict:transformDict structDefine:transformStructDefine];
        CGAffineTransform translatedTransform = CGAffineTransformScale(trans, sx, sy);
        return [self getDictOfStruct:&translatedTransform structDefine:transformStructDefine];
    };

    context[@"CGAffineTransformRotate"]          = ^id(NSDictionary *transformDict, CGFloat angle) {
        CGAffineTransform trans;
        [self getStructDataWidthDict:&trans dict:transformDict structDefine:transformStructDefine];
        CGAffineTransform translatedTransform = CGAffineTransformRotate(trans, angle);
        return [self getDictOfStruct:&translatedTransform structDefine:transformStructDefine];
    };
    
    context[@"CGRectApplyAffineTransform"]       = ^NSDictionary *(NSDictionary *rectDict, NSDictionary *transformDict) {
        CGRect rect;
        CGAffineTransform transform;
        [self getStructDataWidthDict:&transform dict:transformDict structDefine:transformStructDefine];
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect retRect = CGRectApplyAffineTransform(rect, transform);
        return [JPCGGeometry rectDictOfStruct:&retRect];
    };
}

+ (NSDictionary *)transDictOfStruct:(CGAffineTransform *)trans
{
    return [self getDictOfStruct:trans structDefine:transformStructDefine ? transformStructDefine : TRANSFORM_DEFINE];
}
+ (void)transStruct:(CGAffineTransform *)trans ofDict:(NSDictionary *)dict
{
    [self getStructDataWidthDict:trans dict:dict structDefine:transformStructDefine ? transformStructDefine : TRANSFORM_DEFINE];
}

@end
