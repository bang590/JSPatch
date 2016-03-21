//
//  JPViewController.m
//  JSPatch
//
//  Created by bang on 15/5/2.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPViewController.h"
#import "JPFullDemoViewController.h"

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *demoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 50)];
    [demoBtn setTitle:@"Push JPTableViewController" forState:UIControlStateNormal];
    [demoBtn addTarget:self action:@selector(demoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [demoBtn setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:demoBtn];
    
    UIButton *fullDemoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 50)];
    [fullDemoBtn setTitle:@"Push JPFullDemoViewController" forState:UIControlStateNormal];
    [fullDemoBtn addTarget:self action:@selector(fullDemoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [fullDemoBtn setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:fullDemoBtn];
}

- (void)demoBtn:(id)sender {
    NSLog(@"Not use JSpatch,Objcetive C demoBtn Click Event");
}
- (void)fullDemoBtn:(id)sender {
    NSLog(@"Not use JSpatch,Objcetive C fullDemoBtn Click Event");
    JPFullDemoViewController *vc = [[JPFullDemoViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end


