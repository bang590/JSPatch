//
//  JPViewController.h
//  JSPatch
//
//  Created by bang on 15/5/2.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JPViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSString *JPString;

@property(nonatomic,strong)NSMutableArray *JPArray;

@property(nonatomic,strong)NSDictionary *JPDictionary;

@property(nonatomic,strong)UITableView *JPTableView;

@end
