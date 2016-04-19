//
//  JPObject.m
//  JSPatchDemo
//
//  Created by GinVan on 16/4/19.
//  Copyright © 2016年 bang. All rights reserved.
//

#import "JPObject.h"

@implementation JPObject

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"Object %@ is +alloced", self);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Object %@ is -dealloc", self);
}

@end
