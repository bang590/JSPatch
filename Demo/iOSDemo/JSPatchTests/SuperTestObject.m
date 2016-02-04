//
//  SuperTest.m
//  JSPatchDemo
//
//  Created by Awhisper on 16/1/28.
//  Copyright © 2016年 bang. All rights reserved.
//

#import "SuperTestObject.h"

@implementation SuperTestB

-(void)testSuper
{
    NSLog(@" ==== print test B ===");
}

@end

@implementation SuperTestA
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.hasTestSuperA = NO;
    }
    return self;
}

-(void)testSuper
{
    self.hasTestSuperA = YES;
    NSLog(@" === print test A ====");
}

@end

@implementation SuperTestC

-(void)testSuper
{
    [super testSuper];
    NSLog(@" === print test C ====");
}

@end
