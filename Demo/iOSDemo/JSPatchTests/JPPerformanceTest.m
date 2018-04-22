//
//  JPPerformanceTest.m
//  JSPatchDemo
//
//  Created by bang on 4/5/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPPerformanceTest.h"
#import <UIKit/UIKit.h>

@implementation JPPerformanceTest

//overrided in JS
- (void)testJSCallOCEmptyMethod {}
- (void)testJSCallOCMethodWithParamObject{}
- (void)testJSCallOCMethodReturnObject{}

- (void)testJSCallJSEmptyMethod{}
- (void)testJSCallJSMethodWithLargeDictionaryParam{}
- (void)testJSCallJSMethodWithLargeDictionaryParamAutoConvert{}
- (void)testJSCallJSMethodWithParam{}


- (void)testOCCallEmptyMethod {
    for (int i = 0; i < 10000; i ++) {
        [self emptyMethodToOverride];
    }
}

- (void)testOCCallMethodWithParamObject {
    NSObject *obj = [[NSObject alloc] init];
    for (int i = 0; i < 10000; i ++) {
        [self methodWithParamObjectToOverride:obj];
    }
}

- (void)testOCCallMethodReturnObject {
    id ret;
    for (int i = 0; i < 10000; i ++) {
        ret = [self methodReturnObjectToOverride];
    }
}

- (void)testJSCallMallocJPMemory{}
- (void)testJSCallMallocJPCFunction{}

#pragma mark performance
static NSObject *testPerformanceObj;
- (void)initTestPerformanceObj {
    if (!testPerformanceObj) testPerformanceObj = [[NSObject alloc] init];
}
- (void)emptyMethod {
}

- (void)methodWithParamObject:(NSObject *)obj {
    
}
- (NSObject *)methodReturnObject {
    return testPerformanceObj;
}

- (void)emptyMethodToOverride {
    
}
- (void)methodWithParamObjectToOverride:(NSObject *)obj {
    
}
- (NSObject *)methodReturnObjectToOverride {
    return nil;
}

- (void)allArgSumWithBlock:(double (^)(CGFloat arg0, CGPoint arg1, NSInteger arg2, id arg3))block {
    
    NSNumber *arg3 = [NSNumber numberWithDouble:3.3];
    double sum = block(3.2, (CGPoint){1.1,1.2}, 10,arg3);
    NSLog(@"==== sum = %@",@(sum));
}


@end
