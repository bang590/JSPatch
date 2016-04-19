//
//  JSContext+GarbageCollection.m
//  JSPatchDemo
//
//  Created by GinVan on 16/4/18.
//  Copyright © 2016年 bang. All rights reserved.
//

#import "JSContext+GarbageCollection.h"

//@See: http://stackoverflow.com/questions/35689482/force-garbage-collection-of-javascriptcore-virtual-machine-on-ios
JS_EXPORT void JSSynchronousGarbageCollectForDebugging(JSContextRef ctx);

@implementation JSContext (GarbageCollection)

-(void)garbageCollect {
    JSSynchronousGarbageCollectForDebugging(self.JSGlobalContextRef);
}

@end
