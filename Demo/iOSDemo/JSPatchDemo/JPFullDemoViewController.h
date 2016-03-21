//
//  JPViewController.h
//  JSPatch
//
//  Created by RainbowColor on 15/5/2.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JPFullDemoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSString *jpString;

@property(nonatomic,strong)NSMutableArray *jpArray;

@property(nonatomic,strong)NSDictionary *jpDictionary;

@property(nonatomic,strong)UITableView *jpTableView;

@end
