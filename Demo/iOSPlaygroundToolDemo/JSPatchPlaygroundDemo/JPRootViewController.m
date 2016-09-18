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
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"projectPath"];;
    
    NSString *scriptPath = [NSString stringWithFormat:@"%@/js/%@", rootPath, @"/demo.js"];
    [JPPlayground setReloadCompleteHandler:^{
        [self showController];
    }];
    [JPPlayground startPlaygroundWithJSPath:scriptPath];
    
#else
    //正常执行JSPatch
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSString *scriptPath = [rootPath stringByAppendingPathComponent:@"demo.js"];
    [JPEngine evaluateScriptWithPath:scriptPath];
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
    if (clz) {
        id vc = [[clz alloc]init];
        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:vc animated:NO];
    }
}


@end
