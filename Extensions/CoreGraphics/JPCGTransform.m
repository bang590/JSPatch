//
//  JPCGTransform.m
//  JSPatchDemo
//
//  Created by bang on 15/6/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPCGTransform.h"

@implementation JPCGTransform
- (void)main:(JSContext *)context
{
    context[@"CGAffineTransformMakeTranslation"] = ^id(CGFloat tx, CGFloat ty) {
    CGAffineTransform trans                      = CGAffineTransformMakeTranslation(tx, ty);
        return [JPCGTransform transDictOfStruct:&trans];
    };

    context[@"CGAffineTransformMakeRotation"]    = ^id(CGFloat angle) {
        CGAffineTransform trans = CGAffineTransformMakeRotation(angle);
        return [JPCGTransform transDictOfStruct:&trans];
    };

    context[@"CGAffineTransformMakeScale"]       = ^id(CGFloat sx, CGFloat sy) {
        CGAffineTransform trans = CGAffineTransformMakeScale(sx, sy);
        return [JPCGTransform transDictOfStruct:&trans];
    };
    
    context[@"CGAffineTransformTranslate"]       = ^id(NSDictionary *transformDict, CGFloat tx, CGFloat ty) {
        CGAffineTransform trans;
        [JPCGTransform transStruct:&trans ofDict:transformDict];
        CGAffineTransform translatedTransform = CGAffineTransformTranslate(trans, tx, ty);
        return [JPCGTransform transDictOfStruct:&translatedTransform];
    };

    context[@"CGAffineTransformScale"]           = ^id(NSDictionary *transformDict, CGFloat sx, CGFloat sy) {
        CGAffineTransform trans;
        [JPCGTransform transStruct:&trans ofDict:transformDict];
        CGAffineTransform translatedTransform = CGAffineTransformScale(trans, sx, sy);
        return [JPCGTransform transDictOfStruct:&translatedTransform];
    };

    context[@"CGAffineTransformRotate"]          = ^id(NSDictionary *transformDict, CGFloat angle) {
        CGAffineTransform trans;
        [JPCGTransform transStruct:&trans ofDict:transformDict];
        CGAffineTransform translatedTransform = CGAffineTransformRotate(trans, angle);
        return [JPCGTransform transDictOfStruct:&translatedTransform];
    };
    
    context[@"CGRectApplyAffineTransform"]       = ^NSDictionary *(NSDictionary *rectDict, NSDictionary *tDict) {
        CGRect rect;
        CGAffineTransform transform;
        [JPCGTransform transStruct:&transform ofDict:tDict];
        [JPCGGeometry rectStruct:&rect ofDict:rectDict];
        CGRect retRect = CGRectApplyAffineTransform(rect, transform);
        return [JPCGGeometry rectDictOfStruct:&retRect];
    };
}

+ (NSDictionary *)transDictOfStruct:(CGAffineTransform *)trans
{
    return @{@"tx": @(trans->tx), @"ty": @(trans->ty), @"a": @(trans->a), @"b": @(trans->b), @"c": @(trans->c), @"d": @(trans->d)};
}

+ (void)transStruct:(CGAffineTransform *)trans ofDict:(NSDictionary *)dict
{
    trans->tx = [dict[@"tx"] floatValue];
    trans->ty = [dict[@"ty"] floatValue];
    trans->a = [dict[@"a"] floatValue];
    trans->b = [dict[@"b"] floatValue];
    trans->c = [dict[@"c"] floatValue];
    trans->d = [dict[@"d"] floatValue];
}


- (size_t)sizeOfStructWithTypeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"CGAffineTransform"]) {
        return sizeof(CGAffineTransform);
    }
    return 0;
}

- (NSDictionary *)dictOfStruct:(void *)structData typeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"CGAffineTransform"]) {
        CGAffineTransform *trans = (CGAffineTransform *)structData;
        return [JPCGTransform transDictOfStruct:trans];
    }
    return nil;
}

- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"CGAffineTransform"]) {
        [JPCGTransform transStruct:structData ofDict:dict];
    }
}
@end
