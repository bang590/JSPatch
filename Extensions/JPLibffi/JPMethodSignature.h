//
//  JPMethodSignature.h
//  JSPatch
//
//  Created by bang on 1/19/17.
//  Copyright © 2017 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ffi.h"

@interface JPMethodSignature : NSObject

@property (nonatomic, readonly) NSString *types;
@property (nonatomic, readonly) NSArray *argumentTypes;
@property (nonatomic, readonly) NSString *returnType;

- (instancetype)initWithObjCTypes:(NSString *)objCTypes;
- (instancetype)initWithBlockTypeNames:(NSString *)typeNames;

+ (ffi_type *)ffiTypeWithEncodingChar:(const char *)c;
+ (NSString *)typeEncodeWithTypeName:(NSString *)typeName;

@end
