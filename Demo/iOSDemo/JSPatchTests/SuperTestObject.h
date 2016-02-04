//
//  SuperTest.h
//  JSPatchDemo
//
//  Created by Awhisper on 16/1/28.
//  Copyright © 2016年 bang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SuperTestA : NSObject

@property (nonatomic,assign) BOOL hasTestSuperA;
-(void)testSuper;
@end

@interface SuperTestB : SuperTestA

-(void)testSuper;
@end

@interface SuperTestC : SuperTestB

-(void)testSuper;
@end

