//
//  GYMonitor.m
//  GYMonitor
//
//  Created by Zepo She on 2/6/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "GYMonitor.h"
#import "GYFPSMonitor.h"
#import "GYMainThreadMonitor.h"
#import "GYApplication.h"

NSString *const GYMonitorFileSqlite = @"SqlProfile";
NSString *const GYMonitorFileFPS = @"FPS";
NSString *const GYMonitorFileUserEvent = @"UserEvent";


@implementation GYMonitor {
    NSMutableDictionary *_fileWriters;
}

+ (GYMonitor *)sharedInstance {
    static dispatch_once_t pred;
    static GYMonitor *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[GYMonitor alloc] init];
    });
    
    return sharedInstance;
}

- (void)startMonitor
{
    if (self.monitorFPS) {
        [[GYFPSMonitor shareInstance] start];
    }
    if (self.monitorMainThread) {
        [[GYMainThreadMonitor shareInstance] start];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileWriters = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
