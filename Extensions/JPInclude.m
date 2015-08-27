//
//  JPInclude.m
//  JSPatchDemo
//
//  Created by bang on 15/6/29.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPInclude.h"

@implementation JPInclude
+ (void)main:(JSContext *)context
{
    context[@"include"] = ^(NSString *filePath) {
        NSArray *component = [filePath componentsSeparatedByString:@"."];
        if (component.count > 1) {
            NSString *testPath = [[NSBundle bundleForClass:[self class]] pathForResource:component[0] ofType:component[1]];
            [JPEngine evaluateScriptWithPath:testPath];
        }
    };
}
@end
