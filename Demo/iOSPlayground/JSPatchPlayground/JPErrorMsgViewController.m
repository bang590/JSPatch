//
//  JPErrorMsgViewController.m
//  JSPatchPlayground
//
//  Created by bang on 5/14/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPErrorMsgViewController.h"

@interface JPErrorMsgViewController ()
@property (nonatomic) NSString *msg;
@end

@implementation JPErrorMsgViewController

- (instancetype)initWithMsg:(NSString *)msg
{
    self = [super init];
    if (self) {
        self.msg = msg;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITextView *textView = [[UITextView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    textView.scrollEnabled = YES;
    textView.text = self.msg;
    [self.view addSubview:textView];
    
    self.title = @"JSPatch Error";
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(handleBack)]];
}

- (void)handleBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
