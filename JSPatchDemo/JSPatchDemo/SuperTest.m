//
//  SuperTest.m
//  JSPatchDemo
//
//  Created by Awhisper on 16/1/28.
//  Copyright © 2016年 bang. All rights reserved.
//

#import "SuperTest.h"

@implementation SuperTestB

-(void)testSuper
{
    NSLog(@" ==== print test B ===");
}

@end

@implementation SuperTestA

-(void)testSuper
{
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
