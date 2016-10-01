//
//  JPDispatch.m
//  JSPatchDemo
//
//  Created by bang on 10/9/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPDispatch.h"

@implementation JPDispatch
+ (void)main:(JSContext *)context
{
    /* CONSTANT */
    context[@"_DISPATCH_QUEUE_PRIORITY_BACKGROUND"] = ^id() {
        return @(DISPATCH_QUEUE_PRIORITY_BACKGROUND);
    };
    
    context[@"_DISPATCH_TIME_FOREVER"] = ^id() {
        return @(DISPATCH_TIME_FOREVER);
    };
    context[@"_DISPATCH_TIME_NOW"] = ^id() {
        return @(DISPATCH_TIME_NOW);
    };
    context[@"_DISPATCH_QUEUE_CONCURRENT"] = ^id() {
        return [self formatPointerOCToJS:(__bridge void *)DISPATCH_QUEUE_CONCURRENT];
    };
    
    context[@"dispatch_time"] = ^id(double second) {
        return @(dispatch_time(DISPATCH_TIME_NOW, second * NSEC_PER_SEC));
    };
    
    
    /* queue */
    context[@"dispatch_get_global_queue"] = ^id(long identifier, unsigned long flags) {
        return dispatch_get_global_queue(identifier, flags);
    };
    
    context[@"dispatch_get_main_queue"] = ^id(long identifier, unsigned long flags) {
        return dispatch_get_main_queue();
    };
    
    context[@"dispatch_queue_create"] = ^id(NSString *queueName, JSValue *attrJS) {
        dispatch_queue_attr_t attr = [self formatPointerJSToOC:attrJS];
        dispatch_queue_t queue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], attr);
        return queue;
    };
    
    
    /* dispatch & dispatch_barrier */
    context[@"dispatch_async"] = ^void(JSValue *queue, JSValue *cb) {
        dispatch_async([self formatJSToOC:queue], ^{
            [cb callWithArguments:nil];
        });
    };
    
    context[@"dispatch_sync"] = ^void(JSValue *queue, JSValue *cb) {
        dispatch_sync([self formatJSToOC:queue], ^{
            [cb callWithArguments:nil];
        });
    };
    
    context[@"dispatch_barrier_async"] = ^void(JSValue *queue, JSValue *cb) {
        dispatch_barrier_async([self formatJSToOC:queue], ^{
            [cb callWithArguments:nil];
        });
    };
    
    context[@"dispatch_barrier_sync"] = ^void(JSValue *queue, JSValue *cb) {
        dispatch_barrier_sync([self formatJSToOC:queue], ^{
            [cb callWithArguments:nil];
        });
    };
    
    context[@"dispatch_apply"] = ^void(size_t iterations, JSValue *queue, JSValue *cb) {
        dispatch_apply(iterations, [self formatJSToOC:queue], ^(size_t index) {
            [cb callWithArguments:@[@(index)]];
        });
    };
    
    
    
    /* dispatch_group */
    context[@"dispatch_group_create"] = ^id() {
        dispatch_group_t group = dispatch_group_create();
        return group;
    };
    
    context[@"dispatch_group_async"] = ^void(JSValue *group, JSValue *queue, JSValue *cb) {
        dispatch_group_async([self formatJSToOC:group], [self formatJSToOC:queue], ^{
            [cb callWithArguments:nil];
        });
    };
    
    context[@"dispatch_group_wait"] = ^void(JSValue *group, uint64_t dispatch_time) {
        dispatch_group_wait([self formatJSToOC:group], dispatch_time);
    };
    
    context[@"dispatch_group_notify"] = ^void(JSValue *group, JSValue *queue, JSValue *cb) {
        dispatch_group_notify([self formatJSToOC:group], [self formatJSToOC:queue], ^{
            [cb callWithArguments:nil];
        });
    };
    
    context[@"dispatch_group_enter"] = ^void(JSValue *group) {
        dispatch_group_enter([self formatJSToOC:group]);
    };
    
    context[@"dispatch_group_leave"] = ^void(JSValue *group) {
        dispatch_group_leave([self formatJSToOC:group]);
    };
    
    
    [context evaluateScript:@"  \
     global.DISPATCH_QUEUE_PRIORITY_HIGH = 2;   \
     global.DISPATCH_QUEUE_PRIORITY_DEFAULT = 0;    \
     global.DISPATCH_QUEUE_PRIORITY_LOW = -2;   \
     global.DISPATCH_QUEUE_PRIORITY_BACKGROUND = _DISPATCH_QUEUE_PRIORITY_BACKGROUND();  \
     global.DISPATCH_TIME_NOW = _DISPATCH_TIME_NOW();   \
     global.DISPATCH_TIME_FOREVER = _DISPATCH_TIME_FOREVER();   \
     global.DISPATCH_QUEUE_CONCURRENT = _DISPATCH_QUEUE_CONCURRENT();   \
     global.DISPATCH_QUEUE_SERIAL = 0;   \
     "];
}

@end
