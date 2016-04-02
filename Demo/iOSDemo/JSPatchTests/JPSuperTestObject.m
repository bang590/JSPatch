//
//  JPSuperTestObject.m
//  JSPatchDemo
//
//  Created by bang on 4/1/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPSuperTestObject.h"

@implementation JPSuperTestA

- (NSString *)method {
    return @"A";
}

@end


@implementation JPSuperTestB

- (NSString *)method {
    return @"B";
}

@end

@implementation JPSuperTestB1

- (NSString *)method {
    return [NSString stringWithFormat:@"%@%@", [super method], @"1"];
}

@end





@implementation JPSuperTestC

- (NSString *)method {
    return @"C";
}

@end

@implementation JPSuperTestC1

- (NSString *)method {
    return [NSString stringWithFormat:@"%@%@", [super method], @"1"];
}

@end

@implementation JPSuperTestC2

- (NSString *)method {
    return [NSString stringWithFormat:@"%@%@", [super method], @"2"];
}

@end





@implementation JPSuperTestResult

+ (BOOL)isPassA {
    return NO;
}

+ (BOOL)isPassB {
    return NO;
}

+ (BOOL)isPassC {
    JPSuperTestC2 *c = [[JPSuperTestC2 alloc] init];
    return [[c method] isEqualToString:@"C1C2"];
}
@end


