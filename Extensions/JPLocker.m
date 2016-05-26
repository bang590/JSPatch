//
//  JPLocker.m
//  JSPatchDemo
//
//  Created by bang on 3/22/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPLocker.h"

@implementation JPLocker
+ (void)main:(JSContext *)context
{
    context[@"synchronized"] = ^void(JSValue *jsVal, JSValue *cb) {
        @synchronized([self formatJSToOC:jsVal]) {
            [cb callWithArguments:nil];
        }
    };
}
@end
