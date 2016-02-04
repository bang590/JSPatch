//
//  newProrotcolTest.h
//  JSPatchDemo
//
//  Created by Awhisper on 15/12/27.
//  Copyright © 2015年 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface baseTestProtocolObject : NSObject

-(int)testProtocol:(BOOL)arg;

-(void)test2Protocol:(NSInteger)arg;

-(void)test3Protocol:(BOOL)arg1 withB:(float)arg2 withC:(CGFloat)arg3;

@end

@interface structTestProtocolObject : NSObject

-(int)testProtocol:(CGRect)arg;

-(CGPoint)test2Protocol:(CGSize)arg;

-(CGSize)test3Protocol:(CGRect)arg1 withB:(float)arg2 withC:(NSInteger)arg3;

@end

@interface objectTestProtocolObject : NSObject

-(int)testProtocol:(NSString*)arg;

-(int)test2Protocol:(NSString*)arg;

-(CGSize)test3Protocol:(NSArray*)arg1 withB:(NSString*)arg2 withC:(NSInteger)arg3;

@end

//typedef void(^name)(void);
@interface specialTestProtocolObject : NSObject

-(void)testProtocol:(SEL)arg;

-(void)test2Protocol:(void(^)(void))arg;

-(void)test3Protocol:(float)arg1 withB:(void(^)(void))arg2 withC:(SEL)arg3;

@end

@interface typeEncodeTestProtocolObject : NSObject

-(void)testProtocol:(id)arg;

-(NSString*)test2Protocol:(NSArray*)arg1 withB:(NSString*)arg2;

@end

@interface classTestProtocolObject : NSObject

+(int)testProtocol:(NSString*)arg;

+(int)test2Protocol:(NSString*)arg;

+(CGSize)test3Protocol:(NSArray*)arg1 withB:(NSString*)arg2 withC:(NSInteger)arg3;

@end

