//
//  JPInheritanceTestObjects.h
//  JSPatchDemo
//
//  Created by Qiu WeiJia on 6/5/15.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InheritTest01ObjectA : NSObject

- (NSString*)m1;
- (NSString*)m2;

@end

@interface InheritTest01ObjectB : InheritTest01ObjectA

- (NSString*)m1;

@end

@interface InheritTest02ObjectA : NSObject

- (NSString*)m1;
- (NSString*)m2;

@end

@interface InheritTest02ObjectB : InheritTest02ObjectA

- (NSString*)m1;

@end

@interface InheritTest02ObjectC : InheritTest02ObjectB

- (NSString*)m2;

@end

@interface InheritTest03ObjectA : NSObject

- (NSString*)m1;
- (NSString*)m2;

@end

@interface InheritTest03ObjectB : InheritTest03ObjectA

- (NSString*)m1;

@end

@interface InheritTest03ObjectC : InheritTest03ObjectA

- (NSString*)m2;

@end