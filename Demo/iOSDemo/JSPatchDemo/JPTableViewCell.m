//
//  JPTableViewCell.m
//  JSPatchDemo
//
//  Created by Hao on 16/3/20.
//  Copyright © 2016年 bang. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define windowWidth  [UIScreen mainScreen].applicationFrame.size.width

#import "JPTableViewCell.h"

@implementation JPTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backView = [[UIView alloc]init];
        backView.frame= CGRectMake(5, 0, windowWidth-10, 170);
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.borderColor = UIColorFromRGB(0xe9e9e9).CGColor;
        backView.layer.borderWidth = 0.5;
        backView.clipsToBounds = YES;
        [self.contentView addSubview:backView];
        
        self.parallaxImage = [[UIImageView alloc]init];
        self.parallaxImage.frame = CGRectMake(0, -40, backView.frame.size.width, 200);
        self.parallaxImage.backgroundColor = [UIColor clearColor];
        self.parallaxImage.clipsToBounds = YES;
        [backView addSubview:_parallaxImage];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 60, windowWidth-10, 30)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:23];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.shadowColor = UIColorFromRGB(0x030303);
        self.titleLabel.shadowOffset = CGSizeMake(1, 1);
        [backView addSubview:self.titleLabel];
        
        self.subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 90, windowWidth-10, 20)];
        self.subtitleLabel.font = [UIFont systemFontOfSize:15];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.shadowColor = UIColorFromRGB(0x030303);
        self.subtitleLabel.shadowOffset = CGSizeMake(1, 1);
        [backView addSubview:self.subtitleLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
    
    float distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
    float difference = CGRectGetHeight(self.parallaxImage.frame) - CGRectGetHeight(self.frame);
    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
    
    CGRect imageRect = self.parallaxImage.frame;
    imageRect.origin.y = (-(difference/2)+move)*2;
    self.parallaxImage.frame = imageRect;
    
}


@end
