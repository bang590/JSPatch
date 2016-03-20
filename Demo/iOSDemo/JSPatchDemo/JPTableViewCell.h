//
//  JPTableViewCell.h
//  JSPatchDemo
//
//  Created by Hao on 16/3/20.
//  Copyright © 2016年 bang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPTableViewCell : UITableViewCell

@property (strong, nonatomic)UIImageView *parallaxImage;
@property (strong, nonatomic)UILabel *titleLabel;
@property (strong, nonatomic)UILabel *subtitleLabel;

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

@end
