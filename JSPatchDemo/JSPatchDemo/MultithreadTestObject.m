//
//  MultithreadTestObject.m
//  JSPatchDemo
//
//  Created by Qiu WeiJia on 15/6/4.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "MultithreadTestObject.h"

@implementation MultithreadTestObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _values = [[NSMutableArray alloc] init];
        
        [_values addObject:[NSNumber numberWithInt:-1]];
        
    }
    return self;
}

- (void)addValueJS:(NSNumber*)number
{
}

- (void)addValue:(NSNumber*)number
{
    if ([_values count] > 0 && [[_values objectAtIndex:0] integerValue] < 0) {
        [_values removeAllObjects];
    }
    [_values addObject:number];
}

- (void)addValueNoPatch:(NSNumber*)number
{
    [_values addObject:number];
}

- (BOOL)checkAllValues
{
    for (NSNumber *num in _values) {
        if ([num intValue] != self.objectId) {
            return FALSE;
        }
    }
    return TRUE;
}

@end
