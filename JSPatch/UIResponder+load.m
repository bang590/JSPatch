//
//  UIResponder+load.m
//  JSPatchDemo
//
//  Created by zhy on 15/5/27.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "UIResponder+load.h"
#import "JPEngine.h"

#define  JSNetPath     @"http://192.168.0.254/js/demo.js"

#define  JSLocalPath   [[NSBundle mainBundle]  pathForResource:@"demo.js" ofType:nil]

#define  loadJSLocalPath   [JPEngine startEngine];\
                            NSString *script = [NSString stringWithContentsOfFile:JSLocalPath encoding:NSUTF8StringEncoding error:nil];\
                            if (script) {\
                                    [JPEngine evaluateScript:script];\
                            };

#define  loadJSNetPath      [JPEngine startEngine];\
                            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:JSNetPath]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {\
                            NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];\
                            if (script) {\
                                    [JPEngine evaluateScript:script];\
                                }\
                            }];

@implementation UIResponder (load)

+(void)load
{
    #ifdef DEBUG
      loadJSLocalPath
    #else
       loadJSNetPath
    #endif
}

@end
