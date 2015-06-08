//
//  GYMonitor.h
//  GYMonitor
//
//  Created by Zepo She on 2/6/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const GYMonitorFileSqlite;
extern NSString *const GYMonitorFileFPS;
extern NSString *const GYMonitorFileUserEvent;

@interface GYMonitor : NSObject

+ (GYMonitor *)sharedInstance;
- (void)startMonitor;


@property (nonatomic, assign) BOOL monitorFPS;
@property (nonatomic, assign) BOOL monitorSqlite;
@property (nonatomic, assign) BOOL monitorMemory;
@property (nonatomic, assign) BOOL monitorMainThread;

@end
