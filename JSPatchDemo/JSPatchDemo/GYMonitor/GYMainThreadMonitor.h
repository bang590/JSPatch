//
//  WRMainThreadMonitor.h
//  WeRead
//
//  Created by Zachwang on 15/2/1.
//  Copyright (c) 2015年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GYMainThreadMonitor : NSObject

@property(nonatomic, assign)BOOL flag;

+ (instancetype)shareInstance;

- (void)start;
@end
