//
//  JPReverter.h
//  JSPatchDemo
//
//  Created by bang on 2/4/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPEngine.h"

@interface JPCleaner : JPExtension
+ (void)cleanAll;
+ (void)cleanClass:(NSString *)className;
@end
