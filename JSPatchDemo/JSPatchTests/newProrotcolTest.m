//
//  newProrotcolTest.m
//  JSPatchDemo
//
//  Created by Awhisper on 15/12/27.
//  Copyright © 2015年 bang. All rights reserved.
//

#import "newProrotcolTest.h"
#import "JPEngine.h"

@implementation baseTestProtocolObject
// no method definition
// no crash means addProtocol success
@end

@implementation structTestProtocolObject
// no method definition
// no crash means addProtocol success
@end

@implementation objectTestProtocolObject
// no method definition
// no crash means addProtocol success
@end

@implementation specialTestProtocolObject
// no method definition
// no crash means addProtocol success
@end

@implementation typeEncodeTestProtocolObject
// no method definition
// no crash means addProtocol success
@end

@implementation classTestProtocolObject
// no method definition
// no crash means addProtocol success
@end

@implementation newProrotcolTest

-(void)testNewProtocol
{
    NSString *jsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"newProtocolTest" ofType:@"js"];
    NSString *jsScript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:jsScript];
    
    //Protocol baseTest
    baseTestProtocolObject *baseTest = [baseTestProtocolObject new];
    int retBaseTest1 = [baseTest testProtocol:YES];
    
    [baseTest test2Protocol:2];
    [baseTest test3Protocol:NO withB:0.2f withC:3.4f];
    NSLog(@"new protocol base test end");
    
    //Protocol structTest
    structTestProtocolObject *structTest = [structTestProtocolObject new];
    int retStructTest1 = [structTest testProtocol:CGRectZero];
    CGPoint retStructTest2 = [structTest test2Protocol:CGSizeZero];
    CGSize retStructTest3 = [structTest test3Protocol:CGRectZero withB:3.1f withC:4];
    NSLog(@"new protocol struct test end");
    
    //Protocol objectTest
    objectTestProtocolObject *objectTest = [objectTestProtocolObject new];
    int retObjectTest1 = [objectTest testProtocol:@"teststring"];
    int retObjectTest2 = [objectTest test2Protocol:@"teststring"];
    CGSize retObjectTest3 = [objectTest test3Protocol:@[@1,@2] withB:@"teststring" withC:2];
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
    NSLog(@"new protocol encode test end");
    
    
    //Protocol classTest
    int retClassTest1 = [classTestProtocolObject testProtocol:@"teststring"];
    int retClassTest2 = [classTestProtocolObject test2Protocol:@"teststring"];
    CGSize retClassTest3 = [classTestProtocolObject test3Protocol:@[@1,@2] withB:@"teststring" withC:2];
    NSLog(@"new protocol object test end");
    
}

@end
