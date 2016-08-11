//
//  ViewController.m
//  JSPatchPlayground
//
//  Created by bang on 5/14/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPRootViewController.h"
#import "JPEngine.h"
#import "JPPlayground.h"



@interface JPRootViewController ()

@end

@implementation JPRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [JPEngine startEngine];
    
    
#if TARGET_IPHONE_SIMULATOR
    //playground调试
    //JS测试包的本地绝对路径
    NSString *rootPath = @"/Users/Awhisper/Desktop/Github/JSPatch/Demo/iOSPlaygroundToolDemo/JSPatchPlaygroundDemo";
    
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"js"];
    NSString *mainScriptPath = [NSString stringWithFormat:@"%@/%@", scriptRootPath, @"demo.js"];
    [JPPlayground setReloadCompleteHandler:^{
        [self showController];
    }];
    [JPPlayground startPlaygroundWithJSPath:mainScriptPath];
    
    
#else
    //正常执行JSPatch
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    
    NSString *scriptPath = [rootPath stringByAppendingPathComponent:@"demo.js"];
    NSString *script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];
#endif
    
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [btn setTitle:@"Push Playground" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showController) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:btn];
}


- (void)showController
{
    Class clz = NSClassFromString(@"JPDemoController");
    id vc = [[clz alloc]init];
    [self.navigationController pushViewController:vc animated:NO];
}


@end
