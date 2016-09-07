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
#import "newProtocolTest.h"
#import "JPSuperTestObject.h"
#import "JPJSClassTest.h"
#import "JPMemory.h"
#import "JPPerformanceTest.h"
#import "JPCFunctionTest.h"
#import "JPNumberTest.h"

@interface JSPatchTests : XCTestCase

@end

@implementation JSPatchTests
- (void)loadPatch:(NSString *)patchName
{
    NSString *jsPath = [[NSBundle bundleForClass:[self class]] pathForResource:patchName ofType:@"js"];
    [JPEngine evaluateScriptWithPath:jsPath];
}

- (void)setUp {
    [super setUp];
    [JPEngine startEngine];
    [JPEngine addExtensions:@[@"JPMemory", @"JPStructPointer", @"JPCoreGraphics", @"JPUIKit"]];
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
    
    // Test for functions which return double/float, cause there's a fatal bug in NSInvocation on iOS7.0
    // This case shall fail if you comment line 957~959 in JPEngine.m on iOS7.0.
    XCTAssert(obj.funcReturnDoublePassed, @"funcReturnDoublePassed");
    
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
    // Test for functions which return double/float, cause there's a fatal bug in NSInvocation on iOS7.0
    // This case shall fail if you comment line 1050~1052 in JPEngine.m on iOS7.0.
    XCTAssert(obj.classFuncToSwizzleReturnDoublePassed, @"classFuncToSwizzleReturnDoublePassed");
    
    XCTAssert(subObj.funcCallSuperSubObjectPassed, @"funcCallSuperSubObjectPassed");
    XCTAssert(subObj.funcCallSuperPassed, @"funcCallSuperPassed");
    XCTAssert(obj.callForwardInvocationPassed, @"callForwardInvocationPassed");
    
    JPTestSwizzledForwardInvocationSubObject *tmp = [[JPTestSwizzledForwardInvocationSubObject alloc] init];
    [tmp callTestSwizzledSuperForwardInvocation];
    XCTAssert(!tmp.callSwizzledSuperForwardInvocationPassed);
    [tmp swizzleSuperForwoardInvocation];
    [tmp callTestSwizzledSuperForwardInvocation];
    XCTAssert(tmp.callSwizzledSuperForwardInvocationPassed);
    
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

- (void)testJSClass
{
    [self loadPatch:@"jsClassTest"];
    XCTAssert([JPJSClassTest isPassA]);
    XCTAssert([JPJSClassTest isPassB]);
    XCTAssert([JPJSClassTest isPassC]);
}

- (void)testSuperClass
{
    [self loadPatch:@"superTest"];
    XCTAssert([JPSuperTestResult isPassA]);
    XCTAssert([JPSuperTestResult isPassB]);
    XCTAssert([JPSuperTestResult isPassC]);
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


- (void)testCFunction
{
    [self loadPatch:@"jsCFunctionTest"];
    XCTAssert([JPCFunctionTest testCfuncWithId], @"testCfuncWithId");
    XCTAssert([JPCFunctionTest testCfuncWithInt], @"testCfuncWithInt");
    XCTAssert([JPCFunctionTest testCfuncWithCGFloat], @"testCfuncWithCGFloat");
    XCTAssert([JPCFunctionTest testCfuncReturnPointer], @"testCfuncReturnPointer");
    XCTAssert([JPCFunctionTest testCFunctionReturnClass], @"testCFunctionReturnClass");
    XCTAssert([JPCFunctionTest testCFunctionVoid], @"testCFunctionVoid");
}

#pragma mark - jsNumberTest

- (void)testJPNumber {
    [self loadPatch:@"jsNumberTest"];
    XCTAssert([JPNumberTest testJPNumNSNumber], @"testJPNumNSNumber");
    XCTAssert([JPNumberTest testJPNumNSDecimalNumber], @"testJPNumNSDecimalNumber");
    XCTAssert([JPNumberTest testJPNumToJS], @"testJPNumToJS");
    XCTAssert([JPNumberTest testJPNUmToOC], @"testJPNumToOC");
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
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallOCEmptyMethod];
    }];
}

- (void)testJSCallMethodWithParamObjectPerformance
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallOCMethodWithParamObject];
    }];
}
- (void)testJSCallMethodReturnObjectPerformance
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallOCMethodReturnObject];
    }];
}
- (void)testOCCallJSEmptyMethodPerformance
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testOCCallEmptyMethod];
    }];
}
- (void)testOCCallJSMethodWithParamObjectPerformance
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testOCCallMethodWithParamObject];
    }];
}
- (void)testOCCallJSMethodReturnObjectPerformance
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testOCCallMethodReturnObject];
    }];
}

- (void)testJSCallJSEmptyMethod
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallJSEmptyMethod];
    }];
}

- (void)testJSCallJSMethodWithParam
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallJSMethodWithParam];
    }];
}

- (void)testJSCallJSMethodWithLargeDictionaryParam
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallJSMethodWithLargeDictionaryParam];
    }];
}

- (void)testJSCallJSMethodWithLargeDictionaryParamAutoConvert
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallJSMethodWithLargeDictionaryParamAutoConvert];
    }];
}

- (void)testJSCallMallocJPMemory
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallMallocJPMemory];
    }];
}

- (void)testJSCallMallocJPCFunction
{
    [self loadPatch:@"performanceTest"];
    JPPerformanceTest *obj = [[JPPerformanceTest alloc] init];
    [self measureBlock:^{
        [obj testJSCallMallocJPCFunction];
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
