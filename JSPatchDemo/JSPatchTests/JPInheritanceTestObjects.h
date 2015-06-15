//
//  JPInheritanceTestObjects.h
//  JSPatchDemo
//
//  Created by Qiu WeiJia on 6/5/15.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPInheritTest01ObjectA : NSObject

- (NSString*)m1;
- (NSString*)m2;

@end

@interface JPInheritTest01ObjectB : JPInheritTest01ObjectA

- (NSString*)m1;

@end

@interface JPInheritTest02ObjectA : NSObject

- (NSString*)m1;
- (NSString*)m2;
- (NSString*)m3;

@end

@interface JPInheritTest02ObjectB : JPInheritTest02ObjectA

- (NSString*)m1;
- (NSString*)m3;

@end

@interface JPInheritTest02ObjectC : JPInheritTest02ObjectB

- (NSString*)m2;

@end

@interface JPInheritTest03ObjectA : NSObject

- (NSString*)m1;
- (NSString*)m2;

@end

@interface JPInheritTest03ObjectB : JPInheritTest03ObjectA

- (NSString*)m1;

@end

@interface JPInheritTest03ObjectC : JPInheritTest03ObjectA

- (NSString*)m2;

@end