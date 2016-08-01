//
//  JPCFunctionTest.m
//  JSPatchDemo
//
//  Created by bang on 6/1/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPCFunctionTest.h"
#import <UIKit/UIKit.h>
#import "JPEngine.h"

static bool voidFuncRet = false;

id cfuncWithId(NSString *str){
    return str;
}

int cfuncWithInt(int num) {
    return num;
}

CGFloat cfuncWithCGFloat(CGFloat num) {
    return num;
}

void *cfuncReturnPointer() {
    char *a = "abc";
    return a;
}

bool cfuncWithPointerIsEqual(char *a) {
    return a[0] == 'a';
}
void cfuncVoid() {
    NSLog(@"dsssdfsdf");
}

@implementation JPCFunctionTest
+ (BOOL)testCfuncWithId{
    return NO;
};
+ (BOOL)testCfuncWithInt{
    return NO;
};
+ (BOOL)testCfuncWithCGFloat{
    return NO;
};
+ (BOOL)testCfuncReturnPointer{
    return NO;
};
+ (BOOL)testCFunctionReturnClass{
    return NO;
};
+ (BOOL)testCFunctionVoid{
    return voidFuncRet;
};
+ (void)setupCFunctionVoidSucc{
    voidFuncRet = true;
}
@end
