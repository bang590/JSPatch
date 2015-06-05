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
#import "JPInheritanceTestObjects.h"
#import "PatchLoader.h"

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
    XCTAssert(obj.funcReturnDictPassed, @"funcReturnDictPassed");
    
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
    XCTAssert(obj.funcToSwizzleReturnRectPassed, @"funcToSwizzleReturnRectPassed");
    XCTAssert(obj.funcToSwizzleReturnPointPassed, @"funcToSwizzleReturnPointPassed");
    XCTAssert(obj.funcToSwizzleReturnSizePassed, @"funcToSwizzleReturnSizePassed");
    XCTAssert(obj.funcToSwizzleReturnRangePassed, @"funcToSwizzleReturnRangePassed");
    
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

- (void)testInheritance
{
    id objB = [[InheritTest01ObjectB alloc] init];
    NSString* m1Return = [objB m1];
    NSString* m2Return = [objB m2];
    
    [PatchLoader LoadPatch:@"InheritTest01Patch"];
    
    XCTAssertNotEqualObjects(m1Return, [objB m1]);
    XCTAssertEqualObjects(@"JP_01ObjB_m1", [objB m1]);
    XCTAssertEqualObjects(m2Return,[objB m2]);
    
    /*expect([objB m1]).notTo.equal(m1Return);
    expect([objB m1]).to.equal(@"JP_01ObjB_m1");
    expect([objB m2]).to.equal(m2Return);*/
    
    
    id objA = [[InheritTest02ObjectA alloc] init];
    objB = [[InheritTest02ObjectB alloc] init];
    id objC = [[InheritTest02ObjectC alloc] init];
    m1Return = [objA m1];
    m2Return = [objA m2];
    NSString* Bm1Return = [objB m1];
    NSString* Bm2Return = [objB m2];
    NSString* Cm1Return = [objC m1];
    NSString* Cm2Return = [objC m2];
    
    [PatchLoader LoadPatch:@"InheritTest02Patch"];
    
    XCTAssertEqualObjects(m1Return,[objA m1]);
    XCTAssertEqualObjects(m2Return,[objA m2]);
    
    XCTAssertNotEqualObjects(Bm1Return,[objB m1]);
    XCTAssertEqualObjects(@"JP_02ObjB_m1",[objB m1]);
    
    XCTAssertEqualObjects(Bm2Return,[objB m2]);
    
    XCTAssertNotEqualObjects(Cm1Return,[objC m1]);
    XCTAssertEqualObjects(@"JP_02ObjB_m1",[objC m1]);
    
    XCTAssertNotEqualObjects(Cm2Return,[objC m2]);
    XCTAssertEqualObjects(@"JP_02ObjC_m2",[objC m2]);

    /*
    expect([objA m1]).to.equal(m1Return);
    expect([objA m2]).to.equal(m2Return);
    
    expect([objB m1]).notTo.equal(Bm1Return);
    expect([objB m1]).to.equal(@"JP_02ObjB_m1");
    expect([objB m2]).to.equal(Bm2Return);
    
    expect([objC m1]).notTo.equal(Cm1Return);
    expect([objC m1]).to.equal(@"JP_02ObjB_m1");
    
    expect([objC m2]).notTo.equal(Cm2Return);
    expect([objC m2]).to.equal(@"JP_02ObjC_m2");
    */
    
    
    objA = [[InheritTest03ObjectA alloc] init];
    objB = [[InheritTest03ObjectB alloc] init];
    objC = [[InheritTest03ObjectC alloc] init];
    m1Return = [objA m1];
    m2Return = [objA m2];
    Bm1Return = [objB m1];
    Bm2Return = [objB m2];
    Cm1Return = [objC m1];
    Cm2Return = [objC m2];
    
    [PatchLoader LoadPatch:@"InheritTest03Patch"];
    
    XCTAssertEqualObjects(m1Return,[objA m1]);
    XCTAssertEqualObjects(m2Return,[objA m2]);
    
    XCTAssertNotEqualObjects(Bm1Return,[objB m1]);
    XCTAssertEqualObjects(@"JP_03ObjB_m1",[objB m1]);
    
    XCTAssertEqualObjects(Bm2Return,[objB m2]);
    
    XCTAssertEqualObjects(Cm1Return,[objC m1]);
    
    XCTAssertNotEqualObjects(Cm2Return,[objC m2]);
    XCTAssertEqualObjects(@"JP_03ObjC_m2",[objC m2]);
    
    /*
    expect([objA m1]).to.equal(m1Return);
    expect([objA m2]).to.equal(m2Return);
    
    expect([objB m1]).notTo.equal(Bm1Return);
    expect([objB m1]).to.equal(@"JP_03ObjB_m1");
    
    expect([objB m2]).to.equal(Bm2Return);
    
    expect([objC m1]).to.equal(Cm1Return);
    
    expect([objC m2]).notTo.equal(Cm2Return);
    expect([objC m2]).to.equal(@"JP_03ObjC_m2");
     */
}

@end
