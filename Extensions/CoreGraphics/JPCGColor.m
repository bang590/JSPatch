//
//  JPCGColor.m
//  JSPatchDemo
//
//  Created by Albert438 on 15/7/3.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPCGColor.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation JPCGColor

+ (void)main:(JSContext *)context
{
    context[@"CGColorCreate"]                = ^id(JSValue *space,
                                    NSArray *componentsArray) {
        CGFloat *components = malloc(componentsArray.count * sizeof(CGFloat));
        for (int i = 0; i < componentsArray.count; i++) {
            components[i] = [componentsArray[i] doubleValue];
        }
        CGColorRef color =  CGColorCreate([self formatPointerJSToOC:space], components);
        free(components);
        return [self formatRetainedCFTypeOCToJS:color];
    };
    
    context[@"CGColorEqualToColor"]          = ^BOOL(JSValue *color1, JSValue *color2) {
        return CGColorEqualToColor([self formatPointerJSToOC:color1], [self formatPointerJSToOC:color2]);
    };
    
    context[@"CGColorGetColorSpace"]         = ^id(JSValue *color) {
        CGColorSpaceRef space = CGColorGetColorSpace([self formatPointerJSToOC:color]);
        return [self formatPointerOCToJS:space];
    };
    
    context[@"CGColorGetComponents"]         = ^NSArray *(JSValue *color) {
        size_t numberOfComponents = CGColorGetNumberOfComponents([self formatPointerJSToOC:color]);
        const CGFloat *componets = CGColorGetComponents([self formatPointerJSToOC:color]);
        NSMutableArray *componentsArray = [NSMutableArray array];
        for (int i = 0 ; i < numberOfComponents ; i++) {
            [componentsArray addObject:[NSNumber numberWithDouble:componets[i]]];
        }
        return componentsArray;
    };
    
    context[@"CGColorGetNumberOfComponents"] = ^size_t(JSValue *color) {
        return CGColorGetNumberOfComponents([self formatPointerJSToOC:color]);
    };
    
    context[@"CGColorRelease"]               = ^void(JSValue *color){
        CGColorRelease([self formatPointerJSToOC:color]);
    };
    
    context[@"CGColorSpaceCreateDeviceGray"] = ^id() {
        return [self formatRetainedCFTypeOCToJS:CGColorSpaceCreateDeviceGray()];
    };
    
    context[@"CGColorSpaceCreateDeviceRGB"]  = ^id() {
        return [self formatRetainedCFTypeOCToJS:CGColorSpaceCreateDeviceRGB()];
    };
    
    context[@"CGColorSpaceCreateDeviceCMYK"] = ^id() {
        return [self formatRetainedCFTypeOCToJS:CGColorSpaceCreateDeviceCMYK()];
    };
    
    context[@"CGColorSpaceCreatePattern"]    = ^id(JSValue *baseSpace) {
        return [self formatRetainedCFTypeOCToJS:CGColorSpaceCreatePattern([self formatPointerJSToOC:baseSpace])];
    };
    
    context[@"CGColorSpaceGetModel"]         = ^NSInteger(JSValue *space) {
        NSInteger model = CGColorSpaceGetModel([self formatPointerJSToOC:space]);
        return model;
    };
    
    context[@"CGColorSpaceRelease"]          = ^void(JSValue *space) {
        CGColorSpaceRelease([self formatPointerJSToOC:space]);
    };
}

@end
