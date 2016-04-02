//
//  JPSuperTestObject.h
//  JSPatchDemo
//
//  Created by bang on 4/1/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPSuperTestA : NSObject

@end


@interface JPSuperTestB : NSObject

@end

@interface JPSuperTestB1 : JPSuperTestB

@end



@interface JPSuperTestC : NSObject

@end

@interface JPSuperTestC1 : JPSuperTestC

@end

@interface JPSuperTestC2 : JPSuperTestC1

@end

@interface JPSuperTestResult : NSObject
+ (BOOL)isPassA;
+ (BOOL)isPassB;
+ (BOOL)isPassC;
@end