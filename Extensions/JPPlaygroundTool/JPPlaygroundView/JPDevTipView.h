//
//  JPTipView.h
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPDevTipView : UIView

+(void)showJPDevTip:(NSString *)msg;

-(instancetype)initWithMsg:(NSString*)msg;

@end
