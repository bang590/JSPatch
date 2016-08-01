//
//  JPCFunctionTest.h
//  JSPatchDemo
//
//  Created by bang on 6/1/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPCFunctionTest : NSObject
+ (BOOL)testCfuncWithId;
+ (BOOL)testCfuncWithInt;
+ (BOOL)testCfuncWithCGFloat;
+ (BOOL)testCfuncReturnPointer;
+ (BOOL)testCFunctionReturnClass;
+ (BOOL)testCFunctionVoid;
@end
