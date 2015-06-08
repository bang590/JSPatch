//
//  WRMainThreadMonitor.m
//  QQMailApp0.9.1
//
//  Created by Zachwang on 15/2/1.
//
//

#import "GYMainThreadMonitor.h"
#include <mach/mach.h>

#import "GYFPSMonitor.h"

#define MAIN_THREAD_REPORT  @"GYMainThreadMonitorKey"

//#import "WRBookOp.h"
@interface GYMainThreadMonitor ()
- (void)stopTimer;
- (void)resetTimer;
@end

void BeforeWaitingObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
//    NSLog(@"BeforeWaitingObserverCallBack");

    [(__bridge GYMainThreadMonitor *)info stopTimer];
}

void BeforeTimersObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
//    NSLog(@"BeforeTimersObserverCallBack");
    [(__bridge GYMainThreadMonitor *)info resetTimer];
}

void BeforeSourcesObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
//    NSLog(@"BeforeSourcesObserverCallBack");
    [(__bridge GYMainThreadMonitor *)info resetTimer];
}

void AfterWaitingObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
//    NSLog(@"AfterWaitingObserverCallBack");

    [(__bridge GYMainThreadMonitor *)info stopTimer];
}

@implementation GYMainThreadMonitor {
    CFRunLoopObserverRef _beforeWaitingObserver;
    CFRunLoopObserverRef _afterWaitingObserver;
    CFRunLoopObserverRef  _beforeTimersObserver;
    CFRunLoopObserverRef _beforeSourcesObserver;
    NSThread *_thread;
    NSTimer *_timer;
    BOOL _isInBackground;
    NSDate *_timeFlag;
    NSString *_preReportThreadInfo;
    NSTimeInterval _interval;
    NSTimeInterval _preInterval;
}

+ (instancetype)shareInstance
{
    static GYMainThreadMonitor *monitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[GYMainThreadMonitor alloc] init];
    });
    return monitor;
}

- (id)init {
    self = [super init];
    if (self) {
        _isInBackground = NO;
        _preReportThreadInfo = nil;
        _interval = 1;
        _preInterval = 1;
        _flag = NO;
    }
    return self;
}

- (void)start
{
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [_thread setName:@"GYMainThreadMonitor"];
    [_thread start];
    
    [[GYFPSMonitor shareInstance] start];
}

- (void)dealloc {
    CFRelease(_beforeWaitingObserver);
    CFRelease(_afterWaitingObserver);
    CFRelease(_beforeSourcesObserver);
    CFRelease(_beforeTimersObserver);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)run
{
    [self watchMainThread];
    while (![_thread isCancelled]) {
        @autoreleasepool {
            NSRunLoop* runloop = [NSRunLoop currentRunLoop];
            NSTimer* timer = [NSTimer timerWithTimeInterval:_interval target:self selector:@selector(onThreadTimer:) userInfo:nil repeats:YES];
            [runloop addTimer:timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
            [runloop run];
        }
    }
}

- (void )onThreadTimer:(id)timer {
    if (_timeFlag) {
       // NSLog(@"onThreadTimer");
        NSDate *now = [NSDate date];
        NSTimeInterval nowInterval =[now timeIntervalSince1970];
        
        NSTimeInterval startInterval = [_timeFlag timeIntervalSince1970];
        NSTimeInterval fpsLastUpdateTime = [GYFPSMonitor shareInstance].lastUpdateTime;
       float cpuUsage = [self cpu_usage];
        NSLog(@"cpuUsage = %f %f %f",cpuUsage, nowInterval - fpsLastUpdateTime, _interval);
        if (nowInterval - startInterval >= _interval ) {//&& nowInterval - fpsLastUpdateTime >= _interval/* && cpuUsage >= 0.0*/)
        }
        
    }
}
- (void)watchMainThread {
    CFRunLoopObserverContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
    _beforeWaitingObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 1, &BeforeWaitingObserverCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _beforeWaitingObserver, kCFRunLoopDefaultMode);
    _beforeSourcesObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopBeforeSources, YES, 0, &BeforeSourcesObserverCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _beforeSourcesObserver, kCFRunLoopDefaultMode);
    _beforeTimersObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopBeforeTimers, YES, 0, &BeforeTimersObserverCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _beforeTimersObserver, kCFRunLoopDefaultMode);
    _afterWaitingObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopAfterWaiting, YES, 0, &AfterWaitingObserverCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _afterWaitingObserver, kCFRunLoopDefaultMode);
    
}

- (void)stopMonitoring {
    [self performSelector:@selector(stopMonitoringTask) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)resumeMonitoring {
    [self performSelector:@selector(resumeMonitoringTask) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)stopTimer {
    [self performSelector:@selector(stopTimerTask) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)resetTimer {
    [self performSelector:@selector(resetTimerTask) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)stopMonitoringTask {
    _isInBackground = YES;
    [self stopTimerTask];
}

- (void)resumeMonitoringTask {
    _isInBackground = NO;
}

- (void)stopTimerTask {
    if(_timeFlag){
        NSLog(@"stop:%f", [[NSDate date] timeIntervalSince1970] - [_timeFlag timeIntervalSince1970]);
    }
    _timeFlag = nil;

}

- (void)resetTimerTask {
    if(_flag && !_timeFlag){
        _timeFlag = [NSDate date];
        _flag = NO;
    }

}

- (void)throwException {
    if (!_isInBackground) {
        @throw [NSException exceptionWithName:@"Deadlock Exception" reason:@"Deadlock" userInfo:nil];
    }
    
}

- (float) cpu_usage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

@end
