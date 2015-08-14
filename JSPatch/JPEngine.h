//
//  JPEngine.h
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface JPEngine : NSObject
+ (void)startEngine;
+ (JSValue *)evaluateScript:(NSString *)script;
+ (JSContext *)context;

+ (void)addExtensions:(NSArray *)extensions;
+ (void)defineStruct:(NSDictionary *)defineDict;
+ (NSMutableDictionary *)registeredStruct;
@end


@interface JPExtension : NSObject
+ (void)main:(JSContext *)context;

+ (void *)formatPointerJSToOC:(JSValue *)val;
+ (id)formatPointerOCToJS:(void *)pointer;
+ (id)formatJSToOC:(JSValue *)val;
+ (id)formatOCToJS:(id)obj;

+ (int)sizeOfStructTypes:(NSString *)structTypes;
+ (void)getStructDataWidthDict:(void *)structData dict:(NSDictionary *)dict structDefine:(NSDictionary *)structDefine;
+ (NSDictionary *)getDictOfStruct:(void *)structData structDefine:(NSDictionary *)structDefine;
@end

