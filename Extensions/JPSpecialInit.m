//
//  JPSpecialInit.m
//  SwiftDemo
//
//  Created by KouArlen on 16/2/25.
//  Copyright © 2016年 Arlen. All rights reserved.
//

#import "JPSpecialInit.h"

@implementation JPSpecialInit

+ (NSCalendar *)calendarWithCalendarIdentifier:(NSString *)iden
{
    return [[NSCalendar alloc] initWithCalendarIdentifier:iden];
}

#if TARGET_OS_IOS
+ (UIWebView *)newWebView
{
    return [[UIWebView alloc] init];
}
#endif

@end
