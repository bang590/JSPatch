//
//  GYFPSMonitor.m
//  GYMonitor
//
//  Created by bang on 15/2/27.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "GYFPSMonitor.h"
#import "GYMonitor.h"
#import "GYApplication.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

const static int criticalFPS = 30;

@implementation GYFPSMonitor {
    CADisplayLink *_displayLink;
    CFTimeInterval _lastUIUpdateTime;
    NSTimeInterval _desiredUpdateInterval;
    NSUInteger _historyCount;
    NSInteger _currentFPS;
    NSTimeInterval _lastUpdateTime;
    BOOL _isPause;
    GYApplication *_application;
}

+ (instancetype)shareInstance
{
    static GYFPSMonitor *fpsMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fpsMonitor = [[GYFPSMonitor alloc] init];
    });
    return fpsMonitor;
}

- (id)init {
    self = [super init];
    if( self ){
        _desiredUpdateInterval = 0.25f;
        _historyCount = 0;
        _currentFPS = 60;
        _isPause = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidBecomeActiveNotification)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillResignActiveNotification)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
        _displayLink.frameInterval = 1;
        [_displayLink setPaused:YES];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        if ([[UIApplication sharedApplication] isKindOfClass:[GYApplication class]]) {
            _application = (GYApplication *)[UIApplication sharedApplication];
        }
    }
    return self;
}


- (void)dealloc
{
    [_displayLink setPaused:YES];
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)applicationDidBecomeActiveNotification
{
    if (!_isPause) {
        [_displayLink setPaused:NO];
    }
}

- (void)applicationWillResignActiveNotification
{
    [_displayLink setPaused:YES];
}


- (void)displayLinkTick
{
    _historyCount += _displayLink.frameInterval;
    
    CFTimeInterval timeSinceLastUIUpdate = _displayLink.timestamp - _lastUIUpdateTime;
    if( _flag) {
        _lastUpdateTime = [[NSDate date] timeIntervalSince1970];
        _lastUIUpdateTime = _displayLink.timestamp;
        _currentFPS = _historyCount / timeSinceLastUIUpdate;
        if ([GYMonitor sharedInstance].monitorFPS) {
            NSString *log = [NSString stringWithFormat:@"%@ | %@ ", @(_currentFPS), [NSDate date]];
            NSLog(@"%@",log);
        }
        _historyCount = 0;
    }
}

- (NSInteger)currentFPS
{
    return _currentFPS;
}

- (CFTimeInterval)lastUpdateTime
{
    return _lastUpdateTime;
}

- (void)start
{
    _isPause = NO;
    [_displayLink setPaused:NO];
}

- (void)pause
{
    _isPause = YES;
    [_displayLink setPaused:YES];
}

@end
