//
//  AppDelegate.m
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "AppDelegate.h"
#import "JPEngine.h"
//#import "JPViewController.h"
//#import "JPPlayground.h"
#import "JPRootViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [JPEngine startEngine];
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [JPEngine evaluateScript:script];
//    
//    [JPPlayground startPlaygroundWithJSPath:sourcePath];
//    
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    JPViewController *rootViewController = [[JPViewController alloc] init];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
//    self.window.rootViewController = navigationController;
//    [self.window makeKeyAndVisible];
//    
//    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
//    return YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    JPRootViewController *rootViewController = [[JPRootViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
