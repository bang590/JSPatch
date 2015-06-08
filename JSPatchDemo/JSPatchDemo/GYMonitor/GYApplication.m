//
//  GYApplication.m
//  GYMonitor
//
//  Created by Zepo She on 2/9/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "GYApplication.h"

#import "GYMonitor.h"
#import "mach/mach_init.h"
#import "mach/task.h"
#import "GYFPSMonitor.h"

@implementation GYApplication {
    CGFloat _keyboardHeight;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
        
        [center addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        [center addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)notification {
    _keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
}

- (void)keyboardWasHidden:(NSNotification*)notification {
    _keyboardHeight = 0;
}

#pragma mark -

- (void)sendEvent:(UIEvent *)event {
    if (![GYMonitor sharedInstance].monitorMemory) {
        return [super sendEvent:event];
    }
    
    BOOL flag = NO;
    NSMutableString *log;
    
    if (event.type == UIEventTypeTouches) {
        for (UITouch *touch in [event allTouches]) {
            if (/*touch.phase == UITouchPhaseBegan || */touch.phase == UITouchPhaseEnded) {
                flag = YES;
                /*
                NSString *phase;
                if (touch.phase == UITouchPhaseBegan) {
                    phase = @"Began";
                } else if (touch.phase == UITouchPhaseEnded) {
                    phase = @"Ended";
                }
                */
                
                NSString *viewDescription;
                CGPoint location = [touch locationInView:self.keyWindow];
                if (_keyboardHeight && location.y > self.keyWindow.bounds.size.height - _keyboardHeight) {
                    viewDescription = @"keyboard";
                } else {
                    UIView *view = [self.keyWindow hitTest:location withEvent:event];
                    viewDescription = NSStringFromClass([view class]);
                    if ([view isKindOfClass:[UIButton class]] && ((UIButton *)view).currentTitle) {
                        viewDescription = [viewDescription mutableCopy];
                        [(NSMutableString *)viewDescription appendFormat:@"(%@)", ((UIButton *)view).currentTitle];
                    }
                }
                log = [[NSMutableString alloc] initWithFormat:@"%lu | %@ | %@",
                       (unsigned long)[event allTouches].count, [NSDate date], viewDescription];
//                log = [[NSMutableString alloc] initWithFormat:@"%p | %@ | %lu | %@ | %@",
//                       touch, phase, (unsigned long)[event allTouches].count, [NSDate date], viewDescription];
                
                break;
            }
        }
    }
    
    [super sendEvent:event];
    
    if (flag) {
        UIViewController *topViewController = [self topViewController];
        [log appendFormat:@" | %@ | %f", NSStringFromClass([topViewController class]), [GYApplication appResidentMemory] / 1024.0 / 1024.0];
        NSLog(@"%@",log);
    }
}

- (UIViewController *)topViewController {
    UIViewController *rootViewController = self.keyWindow.rootViewController;
    UIViewController *topPresentedViewController = [self topPresentedViewController:rootViewController];
    if ([topPresentedViewController isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)topPresentedViewController).topViewController;
    } else {
        return topPresentedViewController;
    }
}

- (UIViewController *)topPresentedViewController:(UIViewController *)viewController {
    if (viewController.presentedViewController) {
        return [self topPresentedViewController:viewController.presentedViewController];
    } else {
        return viewController;
    }
}

+ (NSUInteger)appResidentMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t r = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (r == KERN_SUCCESS) {
        return info.resident_size;
    } else {
        return -1;
    }
}

@end
