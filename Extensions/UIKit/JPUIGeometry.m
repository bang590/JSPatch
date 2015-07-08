//
//  JPUIGeometry.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/6.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPUIGeometry.h"
#import "JPCGGeometry.h"


@implementation JPUIGeometry

- (void)main:(JSContext *)context
{
    context[@"CGRectFromString"]   = ^NSDictionary *(NSString *string) {
        CGRect rect =  CGRectFromString(string);
        return [JPCGGeometry rectDictOfStruct:&rect];
    };
    
    context[@"CGSizeFromString"]   = ^NSDictionary *(NSString *string) {
        CGSize size =  CGSizeFromString(string);
        return [JPCGGeometry sizeDictOfStruct:&size];
    };
    
    context[@"CGPointFromString"]  = ^NSDictionary *(NSString *string) {
        CGPoint point =  CGPointFromString(string);
        return [JPCGGeometry pointDictOfStruct:&point];
    };
    
    context[@"CGVectorFromString"] = ^NSDictionary *(NSString *string) {
        CGVector vector =  CGVectorFromString(string);
        return [JPCGGeometry vectorDictOfStruct:&vector];
    };
}

+ (void)edgeInsetsStruct:(UIEdgeInsets *)edgeInsets ofDict:(NSDictionary *)dict
{
    edgeInsets->bottom = [dict[@"bottom"] doubleValue];
    edgeInsets->left   = [dict[@"left"] doubleValue];
    edgeInsets->right  = [dict[@"right"] doubleValue];
    edgeInsets->top    = [dict[@"top"] doubleValue];
}

+ (NSDictionary *)edgeInsetOfStruct:(UIEdgeInsets *)edgeInsets
{
    return @{@"bottom": @(edgeInsets->bottom), @"left": @(edgeInsets->left), @"right": @(edgeInsets->right), @"top": @(edgeInsets->top)};
}


- (size_t)sizeOfStructWithTypeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"UIEdgeInsets"]) {
        return sizeof(UIEdgeInsets);
    }
    return 0;
}

- (NSDictionary *)dictOfStruct:(void *)structData typeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"UIEdgeInsets"]) {
        UIEdgeInsets *edgeInsets = (UIEdgeInsets *)structData;
        return [JPUIGeometry edgeInsetOfStruct:edgeInsets];
    }
    return nil;
}

- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeName:(NSString *)typeName
{
    if ([typeName isEqualToString:@"UIEdgeInsets"]) {
        [JPUIGeometry edgeInsetsStruct:structData ofDict:dict];
    }
}

@end
