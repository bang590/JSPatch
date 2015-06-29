//
//  JPEngine.h
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JPEngine : NSObject
+ (void)startEngine;
+ (JSValue *)evaluateScript:(NSString *)script;
+ (JSContext *)context;
@end
