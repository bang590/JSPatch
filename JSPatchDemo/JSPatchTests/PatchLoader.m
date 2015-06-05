//
//  PatchLoader.m
//  JSPatchDemo
//
//  Created by Qiu WeiJia on 6/5/15.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "PatchLoader.h"
#import "JPEngine.h"

@implementation PatchLoader

+ (void)LoadPatch:(NSString *)patchName
{
    NSString *jsPath = [[NSBundle bundleForClass:[self class]] pathForResource:patchName ofType:@"js"];
    NSError *error;
    NSString *jsScript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:&error];
    [JPEngine evaluateScript:jsScript];
}

@end