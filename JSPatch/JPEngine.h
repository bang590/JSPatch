//
//  JPEngine.h
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>


@interface JPEngine : UIResponder

/*!
 @method
 @discussion start the JSPatch engine, execute only once.
 */
+ (void)startEngine;

/*!
 @method
 @description Evaluate Javascript code from a file Path. Call it after +startEngine.
 @param filePath: The filePath of the Javascript code.
 @result The last value generated by the script.
 */
+ (JSValue *)evaluateScriptWithPath:(NSString *)filePath;

/*!
 @method
 @description Evaluate a string of JavaScript code. Call it after +startEngine.
              The method will generate a default resouceURL named "main.js" to the Safari debugger.
 @param script: A string containing the JavaScript code to evaluate.
 @result The last value generated by the script.
 */
+ (JSValue *)evaluateScript:(NSString *)script;

/*!
 @method
 @description Return the JSPatch JavaScript execution environment.
 */
+ (JSContext *)context;



/*!
 @method
 @description Add JPExtension.
 @param extensions: An array containing class name string.
 */
+ (void)addExtensions:(NSArray *)extensions;

/*!
 @method
 @description add new struct type supporting to JS
 @param defineDict: the definition of struct, for Example:
    @{
      @"name": @"CGAffineTransform",   //struct name
      @"types": @"ffffff",  //struct types
      @"keys": @[@"a", @"b", @"c", @"d", @"tx", @"ty"]  //struct keys in JS
    }
 */
+ (void)defineStruct:(NSDictionary *)defineDict;

@end



@interface JPExtension : NSObject
+ (void)main:(JSContext *)context;

+ (void *)formatPointerJSToOC:(JSValue *)val;
+ (id)formatRetainedCFTypeOCToJS:(CFTypeRef)CF_CONSUMED type;
+ (id)formatPointerOCToJS:(void *)pointer;
+ (id)formatJSToOC:(JSValue *)val;
+ (id)formatOCToJS:(id)obj;

+ (int)sizeOfStructTypes:(NSString *)structTypes;
+ (void)getStructDataWidthDict:(void *)structData dict:(NSDictionary *)dict structDefine:(NSDictionary *)structDefine;
+ (NSDictionary *)getDictOfStruct:(void *)structData structDefine:(NSDictionary *)structDefine;

/*!
 @method
 @description Return the registered struct definition in JSPatch,
 the key of dictionary is the struct name.
 */
+ (NSMutableDictionary *)registeredStruct;

+ (NSDictionary *)overideMethods;
@end

