//
//  InstaScriptTests.m
//  InstaScriptTests
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "JPEngine.h"
#import "JPTestObject.h"

@interface JSPatchTests : XCTestCase

@end

@implementation JSPatchTests

- (void)setUp {
    [super setUp];
    [JPEngine startEngine];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEngine {
    
    NSString *testPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
    NSString *jsTest = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:testPath] encoding:NSUTF8StringEncoding];
    [JPEngine evaluateScript:jsTest];
    
    JSValue *objValue = [JPEngine context][@"ocObj"];
    JPTestObject *obj = [objValue toObjectOfClass:[JPTestObject class]];
    JSValue *subObjValue = [JPEngine context][@"subObj"];
    JPTestSubObject *subObj = [subObjValue toObjectOfClass:[JPTestSubObject class]];
    
    XCTAssert(obj.funcReturnVoidPassed, @"funcReturnVoidPassed");
    
    XCTAssert(obj.funcReturnStringPassed, @"funcReturnStringPassed");
    
    XCTAssert(obj.funcWithIntPassed, @"funcWithIntPassed");
    
    XCTAssert(obj.funcWithDictAndDoublePassed, @"funcWithDictAndDoublePassed");
    
    XCTAssert(obj.funcWithRectAndReturnRectPassed, @"funcWithRectAndReturnRectPassed");
    XCTAssert(obj.funcWithSizeAndReturnSizePassed, @"funcWithSizeAndReturnSizePassed");
    XCTAssert(obj.funcWithPointAndReturnPointPassed, @"funcWithPointAndReturnPointPassed");
    XCTAssert(obj.funcWithRangeAndReturnRangePassed, @"funcWithRangeAndReturnRangePassed");
    
    XCTAssert(obj.funcReturnViewWithFramePassed, @"funcReturnViewWithFramePassed");
    XCTAssert(obj.funcWithViewAndReturnViewPassed, @"funcWithViewAndReturnViewPassed");
    
    XCTAssert(obj.funcReturnDictStringViewPassed, @"funcReturnDictStringViewPassed");
    XCTAssert(obj.funcReturnDictStringIntPassed, @"funcReturnDictStringIntPassed");
    XCTAssert(obj.funcReturnArrayControllerViewStringPassed, @"funcReturnArrayControllerViewStringPassed");
    
    
    XCTAssert(obj.funcReturnBlockPassed, @"funcReturnBlockPassed");
    XCTAssert(obj.funcReturnObjectBlockPassed, @"funcReturnObjectBlockPassed");
    XCTAssert(obj.callBlockWithStringAndIntPassed, @"callBlockWithStringAndIntPassed");
    XCTAssert(obj.callBlockWithArrayAndViewPassed, @"callBlockWithArrayAndViewPassed");
    XCTAssert(obj.callBlockWithBoolAndBlockPassed, @"callBlockWithBoolAndBlockPassed");
    XCTAssert(obj.callBlockWithObjectAndBlockPassed, @"callBlockWithObjectAndBlockPassed");
    
    XCTAssert(obj.funcToSwizzleWithStringViewIntPassed, @"funcToSwizzleWithStringViewIntPassed");
    XCTAssert(obj.funcToSwizzleViewPassed, @"funcToSwizzleViewPassed");
    XCTAssert(obj.funcToSwizzleViewCalledOriginalPassed, @"funcToSwizzleViewCalledOriginalPassed");
    XCTAssert(obj.funcToSwizzleReturnViewPassed, @"funcToSwizzleReturnViewPassed");
    XCTAssert(obj.funcToSwizzleParamNilPassed, @"funcToSwizzleParamNilPassed");
    XCTAssert(obj.funcToSwizzleReturnIntPassed, @"funcToSwizzleReturnIntPassed");
    XCTAssert(obj.funcToSwizzleWithBlockPassed, @"funcToSwizzleWithBlockPassed");
    XCTAssert(obj.funcToSwizzle_withUnderLine_Passed, @"funcToSwizzle_withUnderLine_Passed");
    
    XCTAssert(obj.classFuncToSwizzlePassed, @"classFuncToSwizzlePassed");
    XCTAssert(obj.classFuncToSwizzleReturnObjPassed, @"classFuncToSwizzleReturnObjPassed");
    XCTAssert(obj.classFuncToSwizzleReturnObjCalledOriginalPassed, @"classFuncToSwizzleReturnObjCalledOriginalPassed");
    XCTAssert(obj.classFuncToSwizzleReturnIntPassed, @"classFuncToSwizzleReturnIntPassed");
    XCTAssert(obj.callCustomFuncPassed, @"callCustomFuncPassed");
    
    XCTAssert(subObj.funcCallSuperSubObjectPassed, @"funcCallSuperSubObjectPassed");
    XCTAssert(subObj.funcCallSuperPassed, @"funcCallSuperPassed");
    XCTAssert(obj.callForwardInvocationPassed, @"callForwardInvocationPassed");
    
    XCTAssert(obj.propertySetFramePassed, @"propertySetFramePassed");
    XCTAssert(obj.propertySetViewPassed, @"propertySetViewPassed");
    
    XCTAssert(obj.newTestObjectReturnViewPassed, @"newTestObjectReturnViewPassed");
    XCTAssert(obj.newTestObjectReturnBoolPassed, @"newTestObjectReturnBoolPassed");
    XCTAssert(obj.newTestObjectCustomFuncPassed, @"newTestObjectCustomFuncPassed");
    
    XCTAssertEqualObjects(@"overrided",[subObj funcOverrideParentMethod]);
}

@end
