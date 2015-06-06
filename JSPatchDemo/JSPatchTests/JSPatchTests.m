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
#import "JPMultithreadTestObject.h"

@interface PatchLoader : NSObject

+ (void)loadPatch:(NSString*)patchName;

@end

@implementation PatchLoader

+ (void)loadPatch:(NSString *)patchName
{
    NSString *jsPath = [[NSBundle bundleForClass:[self class]] pathForResource:patchName ofType:@"js"];
    NSError *error;
    NSString *jsScript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:&error];
    [JPEngine evaluateScript:jsScript];
}

@end

void thread(void* context);

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
    /*get values before patch*/
    id t1objB = [[InheritTest01ObjectB alloc] init];
    NSString* t1m1Return = [t1objB m1];
    NSString* t1m2Return = [t1objB m2];
    
    id t2objA = [[InheritTest02ObjectA alloc] init];
    id t2objB = [[InheritTest02ObjectB alloc] init];
    id t2objC = [[InheritTest02ObjectC alloc] init];
    NSString* t2m1Return = [t2objA m1];
    NSString* t2m2Return = [t2objA m2];
    NSString* t2Bm1Return = [t2objB m1];
    NSString* t2Bm2Return = [t2objB m2];
    NSString* t2Cm1Return = [t2objC m1];
    NSString* t2Cm2Return = [t2objC m2];
    
    id t3objA = [[InheritTest03ObjectA alloc] init];
    id t3objB = [[InheritTest03ObjectB alloc] init];
    id t3objC = [[InheritTest03ObjectC alloc] init];
    NSString* t3m1Return = [t3objA m1];
    NSString* t3m2Return = [t3objA m2];
    NSString* t3Bm1Return = [t3objB m1];
    NSString* t3Bm2Return = [t3objB m2];
    NSString* t3Cm1Return = [t3objC m1];
    NSString* t3Cm2Return = [t3objC m2];
    
    [PatchLoader loadPatch:@"InheritTest"];
    
    /*Test 1*/
    XCTAssertNotEqualObjects(t1m1Return, [t1objB m1]);
    XCTAssertEqualObjects(@"JP_01ObjB_m1", [t1objB m1]);
    XCTAssertEqualObjects(t1m2Return,[t1objB m2]);
    
    /*Test 2*/
    XCTAssertEqualObjects(t2m1Return,[t2objA m1]);
    XCTAssertEqualObjects(t2m2Return,[t2objA m2]);
    
    XCTAssertNotEqualObjects(t2Bm1Return,[t2objB m1]);
    XCTAssertEqualObjects(@"JP_02ObjB_m1",[t2objB m1]);
    
    XCTAssertEqualObjects(t2Bm2Return,[t2objB m2]);
    
    XCTAssertNotEqualObjects(t2Cm1Return,[t2objC m1]);
    XCTAssertEqualObjects(@"JP_02ObjB_m1",[t2objC m1]);
    
    XCTAssertNotEqualObjects(t2Cm2Return,[t2objC m2]);
    XCTAssertEqualObjects(@"JP_02ObjC_m2",[t2objC m2]);
    
    /*Test 3*/
    XCTAssertEqualObjects(t3m1Return,[t3objA m1]);
    XCTAssertEqualObjects(t3m2Return,[t3objA m2]);
    
    XCTAssertNotEqualObjects(t3Bm1Return,[t3objB m1]);
    XCTAssertEqualObjects(@"JP_03ObjB_m1",[t3objB m1]);
    
    XCTAssertEqualObjects(t3Bm2Return,[t3objB m2]);
    
    XCTAssertEqualObjects(t3Cm1Return,[t3objC m1]);
    
    XCTAssertNotEqualObjects(t3Cm2Return,[t3objC m2]);
    XCTAssertEqualObjects(@"JP_03ObjC_m2",[t3objC m2]);
}

dispatch_semaphore_t sem;
int finishcount = 0;
bool success = false;
#define LOOPCOUNT 200

- (void)testDispatchQueue
{
    [PatchLoader loadPatch:@"multithreadTest"];
    
    success = false;
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    for (int i = 0; i < LOOPCOUNT; i++) {
        MultithreadTestObject *obj = [[MultithreadTestObject alloc] init];
        obj.objectId = i;
        [objs addObject:obj];
    }
    
    dispatch_queue_t q1 = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < LOOPCOUNT; i++) {
        dispatch_async_f(q1, (__bridge void*)[objs objectAtIndex:i], thread);
    }
    
    sem = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(sem,DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(success,@"serial queue test failed");
    
    success = false;
    dispatch_queue_t q2 = dispatch_queue_create("concurrent queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < LOOPCOUNT; i++) {
        dispatch_async_f(q2, (__bridge void*)[objs objectAtIndex:i], thread);
    }
    
    sem = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(sem,DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(success,@"concurrent queue test failed");
}

@end

void thread(void* context)
{
    MultithreadTestObject *obj = (__bridge MultithreadTestObject*)context;
    for (int i = 0; i < LOOPCOUNT; i++) {
        [obj addValue:[NSNumber numberWithInt:obj.objectId]];
        //NSLog(@"obj %d ok", obj.objectId);
    }
    
    finishcount++;
    
    if (![obj checkAllValues]) {
        NSLog(@"found wrong data in object %d", obj.objectId);
        dispatch_semaphore_signal(sem);
        return;
    }

    NSLog(@"obj %d ok, count %d ", obj.objectId, finishcount);
    
    if (finishcount == LOOPCOUNT) {
        finishcount = 0;
        success = true;
        dispatch_semaphore_signal(sem);
    }
}
