//
//  JPPlayground.h
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface JPPlayground : NSObject

+(void)startPlaygroundWithJSPath:(NSString *)path;

+(void)setReloadCompleteHandler:(void(^)())complete;

+(void)reload;

@end
