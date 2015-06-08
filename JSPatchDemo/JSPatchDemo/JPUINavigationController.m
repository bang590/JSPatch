//
//  JPUINavigationController.m
//  JSPatch
//
//  Created by tom on 15/6/8.
//  Copyright (c) 2015年 tom. All rights reserved.
//

#import "JPUINavigationController.h"

@interface JPUINavigationController(){
    NSDate *_startDate;
}

@end

@implementation JPUINavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
    }
    return self;
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _startDate = [NSDate date];
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(_startDate){
        NSDate *endDate = [NSDate date];
        NSLog(@"push viewcontroller date:%f", [endDate timeIntervalSince1970] - [_startDate timeIntervalSince1970]);
        _startDate = nil;
    }
}

@end
