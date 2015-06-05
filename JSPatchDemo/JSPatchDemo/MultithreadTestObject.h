//
//  MultithreadTestObject.h
//  JSPatchDemo
//
//  Created by Qiu WeiJia on 15/6/4.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultithreadTestObject : NSObject
{
    NSMutableArray *_values;
}

@property int objectId;

- (instancetype)init;
- (void)addValueJS:(NSNumber*)number;
- (void)addValue:(NSNumber*)number;
- (void)addValueNoPatch:(NSNumber*)number;
- (BOOL)checkAllValues;

@end
