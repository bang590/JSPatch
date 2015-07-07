//
//  JPUIKitStruct.m
//  JSPatchDemo
//
//  Created by BaiduSky on 7/7/15.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPUIKitStruct.h"

@implementation JPUIKitStruct

#pragma mark -
#pragma mark Pubic

+ (NSDictionary *)transDictOfStruct:(UIEdgeInsets *)inset {
    return @{@"top": @(inset->top), @"left": @(inset->left), @"bottom": @(inset->bottom), @"right": @(inset->right)};
}


+ (void)transStruct:(UIEdgeInsets *)trans ofDict:(NSDictionary *)dict {
    trans->top      = [dict[@"top"] floatValue];
    trans->left     = [dict[@"left"] floatValue];
    trans->bottom   = [dict[@"bottom"] floatValue];
    trans->right    = [dict[@"right"] floatValue];
}


#pragma mark -
#pragma mark JPExtensionProtocol

- (void)main:(JSContext *)context {
    
    context[@"UIEdgeInsets"] = ^id(NSDictionary *transformDict, CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
        UIEdgeInsets trans;
        [JPUIKitStruct transStruct:&trans ofDict:transformDict];
        UIEdgeInsets translatedTransform = UIEdgeInsetsMake(top, left, bottom, right);
        return [JPUIKitStruct transDictOfStruct:&translatedTransform];
    };
}


- (size_t)sizeOfStructWithTypeEncoding:(NSString *)typeEncoding {
    if ([typeEncoding rangeOfString:@"UIEdgeInsets"].location == 1) {
        return sizeof(UIEdgeInsets);
    }
    return 0;
}


- (NSDictionary *)dictOfStruct:(void *)structData typeEncoding:(NSString *)typeEncoding {
    if ([typeEncoding rangeOfString:@"UIEdgeInsets"].location == 1) {
        UIEdgeInsets *trans = (UIEdgeInsets *)structData;
        return [JPUIKitStruct transDictOfStruct:trans];
    }
    return nil;
}


- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeEncoding:(NSString *)typeEncoding {
    if ([typeEncoding rangeOfString:@"UIEdgeInsets"].location == 1) {
        [JPUIKitStruct transStruct:structData ofDict:dict];
    }
}

@end
