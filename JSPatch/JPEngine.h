//
//  JPEngine.h
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
@class JPExtension;

@interface JPEngine : NSObject
+ (void)startEngine;
+ (void)addExtensions:(NSArray *)extensions;
+ (JSValue *)evaluateScript:(NSString *)script;
+ (JSContext *)context;
@end


@protocol JPExtensionProtocol <NSObject>
@optional
- (void)main:(JSContext *)context;

- (size_t)sizeOfStructWithTypeEncoding:(NSString *)typeEncoding;
- (NSDictionary *)dictOfStruct:(void *)structData typeEncoding:(NSString *)typeEncoding;
- (void)structData:(void *)structData ofDict:(NSDictionary *)dict typeEncoding:(NSString *)typeEncoding;
@end

@interface JPExtension : NSObject <JPExtensionProtocol>
+ (instancetype)instance;
- (void *)formatPointerJSToOC:(JSValue *)val;
- (id)formatPointerOCToJS:(void *)pointer;
- (id)formatJSToOC:(JSValue *)val;
- (id)formatOCToJS:(id)obj;
@end

