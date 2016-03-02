//
//  InstaScriptTests.m
//  InstaScriptTests
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "JPEngine.h"
#import "JPTestObject.h"
#import "JPInheritanceTestObjects.h"
#import "JPMultithreadTestObject.h"
#import "JPInclude.h"
#import "newProtocolTest.h"
//#import "JPCoreGraphics.h"
//#import "JPUIKit.h"
#import "SuperTestObject.h"
#import "JPMemory.h"
@interface JSPatchTests : XCTestCase

@end

@implementation JSPatchTests
- (void)loadPatch:(NSString *)patchName
{
    NSString *jsPath = [[NSBundle bundleForClass:[self class]] pathForResource:patchName ofType:@"js"];
    NSString *jsScript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:jsScript];
}

- (void)setUp {
    [super setUp];
    [JPEngine startEngine];
    [JPEngine addExtensions:@[@"JPInclude", @"JPMemory", @"JPStructPointer", @"JPCoreGraphics", @"JPUIKit"]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEngine {
    
    [self loadPatch:@"test"];
    
    JSValue *objValue = [JPEngine context][@"ocObj"];
    JPTestObject *obj = [objValue toObjectOfClass:[JPTestObject class]];
    JSValue *subObjValue = [JPEngine context][@"subObj"];
    JPTestSubObject *subObj = [subObjValue toObjectOfClass:[JPTestSubObject class]];
    
    XCTAssert(obj.funcReturnVoidPassed, @"funcReturnVoidPassed");
    
    XCTAssert(obj.funcReturnStringPassed, @"funcReturnStringPassed");
    
    XCTAssert(obj.funcWithIntPassed, @"funcWithIntPassed");
    XCTAssert(obj.funcWithNilPassed, @"funcWithNilPassed");
    XCTAssert(obj.funcReturnNilPassed, @"funcReturnNilPassed");
    XCTAssert(obj.funcWithNilAndOthersPassed, @"funcWithNilAndOthersPassed");
    XCTAssert(obj.funcWithNullPassed, @"funcWithNullPassed");
    XCTAssert(obj.funcTestBoolPassed, @"funcTestBoolPassed");
    XCTAssert(obj.funcTestNSNumberPassed, @"funcTestNSNumberPassed");
    
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
    XCTAssert(obj.funcReturnDictPassed, @"testBoxingObjPassed");
    
    XCTAssert(obj.funcReturnBlockPassed, @"funcReturnBlockPassed");
    XCTAssert(obj.funcReturnObjectBlockPassed, @"funcReturnObjectBlockPassed");
    XCTAssert(obj.funcReturnObjectBlockReturnValuePassed, @"funcReturnObjectBlockReturnValuePassed");
    XCTAssert(obj.callBlockWithStringAndIntPassed, @"callBlockWithStringAndIntPassed");
    XCTAssert(obj.callBlockWithStringAndIntReturnValuePassed, @"callBlockWithStringAndIntReturnValuePassed");
    XCTAssert(obj.callBlockWithArrayAndViewPassed, @"callBlockWithArrayAndViewPassed");
    XCTAssert(obj.callBlockWithBoolAndBlockPassed, @"callBlockWithBoolAndBlockPassed");
    XCTAssert(obj.callBlockWithObjectAndBlockPassed, @"callBlockWithObjectAndBlockPassed");
    XCTAssert(obj.callBlockWithObjectAndBlockReturnValuePassed, @"callBlockWithObjectAndBlockReturnValuePassed");
    
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
    XCTAssert(obj.funcToSwizzleReturnEdgeInsetsPassed, @"funcToSwizzleReturnEdgeInsetsPassed");
    
    
    XCTAssert(obj.funcToSwizzleReturnRectJSPassed, @"funcToSwizzleReturnRectJSPassed");
    XCTAssert(obj.funcToSwizzleReturnPointJSPassed, @"funcToSwizzleReturnPointJSPassed");
    XCTAssert(obj.funcToSwizzleReturnSizeJSPassed, @"funcToSwizzleReturnSizeJSPassed");
    XCTAssert(obj.funcToSwizzleReturnRangeJSPassed, @"funcToSwizzleReturnRangeJSPassed");
    XCTAssert(obj.funcToSwizzleReturnEdgeInsetsJSPassed, @"funcToSwizzleReturnEdgeInsetsJSPassed");
    
    
    XCTAssert(obj.funcToSwizzleTestClassPassed, @"funcToSwizzleTestClassPassed");
    XCTAssert(obj.funcToSwizzleTestSelectorPassed, @"funcToSwizzleTestSelectorPassed");
    XCTAssert(obj.funcToSwizzleTestCharPassed, @"funcToSwizzleTestCharPassed");
    XCTAssert(obj.funcTestCharPassed, @"funcTestCharPassed");
    XCTAssert(obj.funcToSwizzleTestPointerPassed, @"funcToSwizzleTestPointerPassed");
    XCTAssert(obj.funcTestPointerPassed, @"funcTestPointerPassed");
    XCTAssert(obj.funcTestSizeofPassed,@"funcSizeofPassed");
    XCTAssert(obj.funcTestGetPointerPassed, @"funcGetPointerPassed");
    XCTAssert(obj.funcTestNSErrorPointerPassed, @"funcTestNSErrorPointerPassed");
    XCTAssert(obj.funcTestNilParametersInBlockPassed, @"funcTestNilParametersInBlockPassed");
    NSDictionary *originalDict = @{@"k": @"v"};
    NSDictionary *dict = [obj funcToSwizzleReturnDictionary:originalDict];
    XCTAssert(originalDict == dict, @"funcToSwizzleReturnDictionary");
    
    dict = [obj funcToSwizzleReturnJSDictionary];
    XCTAssertEqualObjects(dict[@"str"], @"js_string", @"funcToSwizzleReturnJSDictionary");
    
    NSArray *originalArr = @[@"js", @"patch"];
    NSArray *arr = [obj funcToSwizzleReturnArray:originalArr];
    XCTAssert(originalArr == arr, @"funcToSwizzleReturnArray");
    
    NSString *originalStr = @"JSPatch";
    NSString *str = [obj funcToSwizzleReturnString:originalStr];
    XCTAssert(originalStr == str, @"funcToSwizzleReturnString");
    
    
    XCTAssert(obj.classFuncToSwizzlePassed, @"classFuncToSwizzlePassed");
    XCTAssert(obj.classFuncToSwizzleReturnObjPassed, @"classFuncToSwizzleReturnObjPassed");
    XCTAssert(obj.classFuncToSwizzleReturnObjCalledOriginalPassed, @"classFuncToSwizzleReturnObjCalledOriginalPassed");
    XCTAssert(obj.classFuncToSwizzleReturnIntPassed, @"classFuncToSwizzleReturnIntPassed");
    
    XCTAssert(subObj.funcCallSuperSubObjectPassed, @"funcCallSuperSubObjectPassed");
    XCTAssert(subObj.funcCallSuperPassed, @"funcCallSuperPassed");
    XCTAssert(obj.callForwardInvocationPassed, @"callForwardInvocationPassed");
    
    XCTAssert(obj.propertySetFramePassed, @"propertySetFramePassed");
    XCTAssert(obj.propertySetViewPassed, @"propertySetViewPassed");
    
    XCTAssert(obj.newTestObjectReturnViewPassed, @"newTestObjectReturnViewPassed");
    XCTAssert(obj.newTestObjectReturnBoolPassed, @"newTestObjectReturnBoolPassed");

    XCTAssert(obj.mutableArrayPassed, @"mutableArrayPassed");
    XCTAssert(obj.mutableDictionaryPassed, @"mutableDictionaryPassed");
    XCTAssert(obj.mutableStringPassed, @"mutableStringPassed");
    
    XCTAssert(obj.funcWithTransformPassed, @"funcWithTransformPassed");
    XCTAssert(obj.transformTranslatePassed, @"funcWithTransformPassed");
    XCTAssert(obj.funcWithRectPointerPassed, @"funcWithRectPointerPassed");
    XCTAssert(obj.funcWithTransformPointerPassed, @"funcWithTransformPointerPassed");
    
    XCTAssertEqualObjects(@"overrided",[subObj funcOverrideParentMethod]);
    
    XCTAssert(obj.variableParameterMethodPassed, @"variableParameterMethodPassed");
    
    
    JPTestProtocolObject *testProtocolObj = [[JPTestProtocolObject alloc] init];
    XCTAssert([testProtocolObj testProtocolMethods], @"testProtocolMethodsPassed");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [obj funcToSwizzleTestGCD:^{
        XCTAssert(obj.funcToSwizzleTestGCDPassed, @"funcToSwizzleTestGCDPassed");
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)testSuperClass
{
    [self loadPatch:@"superTest"];
    SuperTestC *testobject = [[SuperTestC alloc]init];
    [testobject testSuper];
    XCTAssert(testobject.hasTestSuperA);
}

- (void)testInheritance
{
    /*get values before patch*/
    id t1objB = [[JPInheritTest01ObjectB alloc] init];
    NSString* t1m1Return = [t1objB m1];
    NSString* t1m2Return = [t1objB m2];
    
    id t2objA = [[JPInheritTest02ObjectA alloc] init];
    id t2objB = [[JPInheritTest02ObjectB alloc] init];
    id t2objC = [[JPInheritTest02ObjectC alloc] init];
    NSString* t2m1Return = [t2objA m1];
    NSString* t2m2Return = [t2objA m2];
    NSString* t2Bm1Return = [t2objB m1];
    NSString* t2Bm2Return = [t2objB m2];
    NSString* t2Cm1Return = [t2objC m1];
    NSString* t2Cm2Return = [t2objC m2];
    
    id t3objA = [[JPInheritTest03ObjectA alloc] init];
    id t3objB = [[JPInheritTest03ObjectB alloc] init];
    id t3objC = [[JPInheritTest03ObjectC alloc] init];
    NSString* t3m1Return = [t3objA m1];
    NSString* t3m2Return = [t3objA m2];
    NSString* t3Bm1Return = [t3objB m1];
    NSString* t3Bm2Return = [t3objB m2];
    NSString* t3Cm1Return = [t3objC m1];
    NSString* t3Cm2Return = [t3objC m2];
    
    [self loadPatch:@"inheritTest"];
    
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
    
    XCTAssertEqualObjects(@"JP_02ObjC_m3", [t2objC m3]);
    
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



#pragma mark - multithreadTest

dispatch_semaphore_t sem;
int finishcount = 0;
bool success = false;
#define LOOPCOUNT 100
void thread(void* context);

- (void)testDispatchQueue
{
    [self loadPatch:@"multithreadTest"];
    
    success = false;
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    for (int i = 0; i < LOOPCOUNT; i++) {
        JPMultithreadTestObject *obj = [[JPMultithreadTestObject alloc] init];
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


void thread(void* context)
{
    JPMultithreadTestObject *obj = (__bridge JPMultithreadTestObject*)context;
    for (int i = 0; i < LOOPCOUNT; i++) {
        [obj addValue:[NSNumber numberWithInt:obj.objectId]];
    }
    
    finishcount++;
    
    if (![obj checkAllValues]) {
        NSLog(@"found wrong data in object %d", obj.objectId);
        dispatch_semaphore_signal(sem);
        return;
    }
    
    if (finishcount == LOOPCOUNT) {
        finishcount = 0;
        success = true;
        dispatch_semaphore_signal(sem);
    }
}




#pragma mark - performance

- (void)testJSCallEmptyMethodPerformance
{
    [self loadPatch:@"test"];
    JPTestObject *obj = [[JPTestObject alloc] init];
    [self measureBlock:^{
        [obj jsCallEmptyMethod];
    }];
}

- (void)testJSCallMethodWithParamObjectPerformance
{
    [self loadPatch:@"test"];
    JPTestObject *obj = [[JPTestObject alloc] init];
    [self measureBlock:^{
        [obj jsCallMethodWithParamObject];
    }];
}
- (void)testJSCallMethodReturnObjectPerformance
{
    [self loadPatch:@"test"];
    JPTestObject *obj = [[JPTestObject alloc] init];
    [self measureBlock:^{
        [obj jsCallMethodReturnObject];
    }];
}
- (void)testOCCallJSEmptyMethodPerformance
{
    [self loadPatch:@"test"];
    JPTestObject *obj = [[JPTestObject alloc] init];
    [self measureBlock:^{
        for (int i = 0; i < 10000; i ++) {
            [obj emptyMethodToOverride];
        }
    }];
}
- (void)testOCCallJSMethodWithParamObjectPerformance
{
    [self loadPatch:@"test"];
    JPTestObject *obj = [[JPTestObject alloc] init];
    [self measureBlock:^{
        for (int i = 0; i < 10000; i ++) {
            [obj methodWithParamObjectToOverride:obj];
        }
    }];
}
- (void)testOCCallJSMethodReturnObjectPerformance
{
    [self loadPatch:@"test"];
    JPTestObject *obj = [[JPTestObject alloc] init];
    [self measureBlock:^{
        for (int i = 0; i < 10000; i ++) {
            [obj methodReturnObjectToOverride];
        }
    }];
}


- (void)testNewProtocol{
    [self loadPatch:@"newProtocolTest"];
    
    //Protocol baseTest
    baseTestProtocolObject *baseTest = [baseTestProtocolObject new];
    int retBaseTest1 = [baseTest testProtocol:YES];
    XCTAssertEqual(retBaseTest1, 1);
    
    [baseTest test2Protocol:2];
    [baseTest test3Protocol:NO withB:0.2f withC:3.4f];
    NSLog(@"new protocol base test end");
    
    //Protocol structTest
    structTestProtocolObject *structTest = [structTestProtocolObject new];
    int retStructTest1 = [structTest testProtocol:CGRectZero];
    XCTAssertEqual(retStructTest1, 1);
    CGPoint retStructTest2 = [structTest test2Protocol:CGSizeZero];
    XCTAssertTrue(CGPointEqualToPoint(retStructTest2, CGPointMake(100, 100)));
    CGSize retStructTest3 = [structTest test3Protocol:CGRectZero withB:3.1f withC:4];
    XCTAssertTrue(CGSizeEqualToSize(retStructTest3, CGSizeMake(100, 100)));
    NSLog(@"new protocol struct test end");
    
    //Protocol objectTest
    objectTestProtocolObject *objectTest = [objectTestProtocolObject new];
    int retObjectTest1 = [objectTest testProtocol:@"teststring"];
    XCTAssertEqual(retObjectTest1, 1);
    int retObjectTest2 = [objectTest test2Protocol:@"teststring"];
    XCTAssertEqual(retObjectTest2, 1);
    CGSize retObjectTest3 = [objectTest test3Protocol:@[@1,@2] withB:@"teststring" withC:2];
    XCTAssertTrue(CGSizeEqualToSize(retObjectTest3, CGSizeMake(100, 100)));
    NSLog(@"new protocol object test end");
    
    //Protocol sepcialTest
    specialTestProtocolObject *specialTest = [specialTestProtocolObject new];
    [specialTest testProtocol:@selector(viewDidLoad)];
    [specialTest test2Protocol:^{
        NSLog(@"11");
    }];
    [specialTest test3Protocol:0.5f withB:^{
        NSLog(@"11");
    } withC:@selector(viewDidLoad)];
    NSLog(@"new protocol special test end");
    
    //Protocol typeEncodeTest
    typeEncodeTestProtocolObject *encodeTest = [typeEncodeTestProtocolObject new];
    [encodeTest testProtocol:@"teststring"];
    NSString* retEncodeTest2 = [encodeTest test2Protocol:@[@1,@2] withB:@"testtest"];
    XCTAssertTrue([retEncodeTest2 isEqualToString:@"string"]);
    NSLog(@"new protocol encode test end");
    
    
    //Protocol classTest
    int retClassTest1 = [classTestProtocolObject testProtocol:@"teststring"];
    XCTAssertEqual(retClassTest1, 1);
    int retClassTest2 = [classTestProtocolObject test2Protocol:@"teststring"];
    XCTAssertEqual(retClassTest2, 1);
    CGSize retClassTest3 = [classTestProtocolObject test3Protocol:@[@1,@2] withB:@"teststring" withC:2];
    XCTAssertTrue(CGSizeEqualToSize(retClassTest3, CGSizeMake(100, 100)));
    NSLog(@"new protocol object test end");
}
@end
