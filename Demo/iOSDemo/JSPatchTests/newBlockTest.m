//
//  newBlockTest.m
//  JSPatchTests
//
//  Created by WELCommand on 2018/3/27.
//  Copyright © 2018年 bang. All rights reserved.
//

#import "newBlockTest.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "JPEngine.h"

@implementation newBlockTest

- (void)testJSBlockToOCCall {}


+ (void)main:(JSContext *)context
{
    context[@"__genBlock"] = nil;
}

- (void)removeJPBlock {
    [JPEngine addExtensions:@[@"newBlockTest"]];
}

- (void)performBlock:(CGFloat (^)(int arg1, CGPoint arg2, double arg3, CGFloat arg4, NSNumber *arg5, NSString *arg6, NSInteger arg7))block {
    _success = (block(1, (CGPoint){3.3, 3.3}, 1.1, 1.1, @(11), @"4.4", 17) == (CGFloat)(1 + 3.3 + 3.3 + 1.1 + 1.1 + 11 + 4.4 + 17)) && (block(1, (CGPoint){3.3, 3.3}, 1.1, 1.1, @(11), @"4.4", 17) == (CGFloat)(1 + 3.3 + 3.3 + 1.1 + 1.1 + 11 + 4.4 + 17));
}

@end
