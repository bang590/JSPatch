//
//  JPProtocol.m
//  JSPatchDemo
//
//  Created by bang on 9/9/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPProtocol.h"
#import <objc/runtime.h>

@implementation JPProtocol
+ (void)main:(JSContext *)context
{
    context[@"protocol"] = ^id(NSString *protocolName) {
        return objc_getProtocol([protocolName cStringUsingEncoding:NSUTF8StringEncoding]);
    };
}
@end
