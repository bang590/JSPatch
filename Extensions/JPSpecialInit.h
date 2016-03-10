//
//  JPSpecialInit.h
//  SwiftDemo
//
//  Created by KouArlen on 16/2/25.
//  Copyright © 2016年 Arlen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 handle the Init of some Special Class
 https://github.com/bang590/JSPatch/issues/248
 
 */

@interface JPSpecialInit : NSObject

+ (NSCalendar *)calendarWithCalendarIdentifier:(NSString *)iden;

@end
