//
//  JPPlaygroundMenu.h
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    JPDevMenuActionReload = 0,
    JPDevMenuActionAutoReload,
    JPDevMenuActionOpenJS,
    JPDevMenuActionCancel
} JPDevMenuAction;

@protocol JPDevMenuDelegate <NSObject>

-(void)devMenuDidAction:(JPDevMenuAction)action withValue:(id)value;

@end

@interface JPDevMenu : NSObject

@property (nonatomic,weak) id<JPDevMenuDelegate> delegate;
- (void)toggle;
@end
