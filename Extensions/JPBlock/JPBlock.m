//
//  JPBlock.m
//  JSPatch
//
//  Created by bang on 1/19/17.
//  Copyright © 2017 bang. All rights reserved.
//

#import "JPBlock.h"
#import "JPBlockWrapper.h"
#import <objc/runtime.h>

@implementation JPBlock
+ (void)main:(JSContext *)context
{
    context[@"__genBlock"] = ^id(NSString *typeString, JSValue *cb) {
        JPBlockWrapper *blockWrapper = [[JPBlockWrapper alloc] initWithTypeString:typeString callbackFunction:cb];
        return blockWrapper;
    };
}

+ (id)blockWithBlockObj:(JPBlockWrapper *)blockObj
{
    void *blockPtr = [blockObj blockPtr];
    id blk = [((__bridge id)blockPtr) copy];
    return blk;
}
@end
