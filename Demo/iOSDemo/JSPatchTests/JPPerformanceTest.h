//
//  JPPerformanceTest.h
//  JSPatchDemo
//
//  Created by bang on 4/5/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPPerformanceTest : NSObject
- (void)testJSCallOCEmptyMethod;
- (void)testJSCallOCMethodWithParamObject;
- (void)testJSCallOCMethodReturnObject;

- (void)testJSCallJSEmptyMethod;
- (void)testJSCallJSMethodWithLargeDictionaryParam;
- (void)testJSCallJSMethodWithLargeDictionaryParamAutoConvert;
- (void)testJSCallJSMethodWithParam;

- (void)testOCCallEmptyMethod;
- (void)testOCCallMethodWithParamObject;
- (void)testOCCallMethodReturnObject;

- (void)testJSCallMallocJPMemory;
- (void)testJSCallMallocJPCFunction;
@end
