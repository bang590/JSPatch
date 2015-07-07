//
//  JPUIKitStruct.h
//  JSPatchDemo
//
//  Created by BaiduSky on 7/7/15.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPEngine.h"

//
#import <UIKit/UIKit.h>

//
@interface JPUIKitStruct : JPExtension

+ (NSDictionary *)transDictOfStruct:(UIEdgeInsets *)inset;
+ (void)transStruct:(UIEdgeInsets *)trans ofDict:(NSDictionary *)dict;

@end
