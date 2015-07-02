//
//  JPCGTransform.m
//  JSPatchDemo
//
//  Created by bang on 15/6/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPCGTransform.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation JPCGTransform
- (void)main:(JSContext *)context
{
    context[@"CGAffineTransformTranslate"] = ^id(NSDictionary *transformDict, CGFloat tx, CGFloat ty) {
        CGAffineTransform trans;
        [self _transStruct:&trans ofDict:transformDict];
        CGAffineTransform translatedTransform = CGAffineTransformTranslate(trans, tx, ty);
        return [self _transDictOfStruct:&translatedTransform];
    };
    
    context[@"CGAffineTransformScale"] = ^id(NSDictionary *transformDict, CGFloat sx, CGFloat sy) {
        CGAffineTransform trans;
        [self _transStruct:&trans ofDict:transformDict];
        CGAffineTransform translatedTransform = CGAffineTransformScale(trans, sx, sy);
        return [self _transDictOfStruct:&translatedTransform];
    };
    
    context[@"CGAffineTransformRotate"] = ^id(NSDictionary *transformDict, CGFloat angle) {
        CGAffineTransform trans;
        [self _transStruct:&trans ofDict:transformDict];
        CGAffineTransform translatedTransform = CGAffineTransformRotate(trans, angle);
        return [self _transDictOfStruct:&translatedTransform];
    };
}

- (NSDictionary *)_transDictOfStruct:(CGAffineTransform *)trans
{
    return @{@"tx": @(trans->tx), @"ty": @(trans->ty), @"a": @(trans->a), @"b": @(trans->b), @"c": @(trans->c), @"d": @(trans->d)};
}

- (void)_transStruct:(CGAffineTransform *)trans ofDict:(NSDictionary *)dict
{
    trans->tx = [dict[@"tx"] floatValue];
    trans->ty = [dict[@"ty"] floatValue];
    trans->a = [dict[@"a"] floatValue];
    trans->b = [dict[@"b"] floatValue];
    trans->c = [dict[@"c"] floatValue];
    trans->d = [dict[@"d"] floatValue];
}


- (size_t)sizeOfStructWithTypeEncoding:(NSString *)typeEncoding
{
    if ([typeEncoding rangeOfString:@"CGAffineTransform"].location == 1) {
        return sizeof(CGAffineTransform);
    }
    return 0;
}

- (NSDictionary *)dictOfStruct:(void *)structData typeEncoding:(NSString *)typeEncoding
{
    if ([typeEncoding rangeOfString:@"CGAffineTransform"].location == 1) {
        CGAffineTransform *trans = (CGAffineTransform *)structData;
        return [self _transDictOfStruct:trans];
    }
    return nil;
}

- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeEncoding:(NSString *)typeEncoding
{
    if ([typeEncoding rangeOfString:@"CGAffineTransform"].location == 1) {
        [self _transStruct:structData ofDict:dict];
    }
}
@end
