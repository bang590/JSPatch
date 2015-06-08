//
//  GYFPSMonitor.h
//  GYMonitor
//
//  Created by bang on 15/2/27.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GYFPSMonitor : NSObject

@property(nonatomic, assign)BOOL flag;

+ (instancetype)shareInstance;
- (void)start;
- (void)pause;
- (NSInteger)currentFPS;
- (CFTimeInterval)lastUpdateTime;
@end
