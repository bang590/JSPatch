//
//  JPErrorView.m
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "JPDevErrorView.h"



@implementation JPDevErrorView

- (instancetype)initError:(NSString *)errMsg
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        UITextView *text = [[UITextView alloc]initWithFrame:CGRectMake(0, 20, self.bounds.size.width, self.bounds.size.height-20)];
        text.backgroundColor = [UIColor redColor];
        text.textColor = [UIColor whiteColor];
        text.font = [UIFont systemFontOfSize:20];
        text.userInteractionEnabled = NO;
        
        text.text = errMsg;
        
        [self addSubview:text];
        
    }
    return self;
}

@end
