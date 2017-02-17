//
//  JPReverter.m
//  JSPatchDemo
//
//  Created by bang on 2/4/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPCleaner.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation JPCleaner
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

+ (void)cleanAll
{
    [self cleanClass:nil];
    [[self includedScriptPaths] removeAllObjects];
}

+ (void)cleanClass:(NSString *)className
{
    NSDictionary *methodsDict = [JPExtension overideMethods];
    for (Class cls in methodsDict.allKeys) {
        if (className && ![className isEqualToString:NSStringFromClass(cls)]) {
            continue;
        }
        for (NSString *jpSelectorName in [methodsDict[cls] allKeys]) {
            NSString *selectorName = [jpSelectorName substringFromIndex:3];
            NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", selectorName];
            
            SEL selector = NSSelectorFromString(selectorName);
            SEL originalSelector = NSSelectorFromString(originalSelectorName);
            IMP originalImp = class_respondsToSelector(cls, originalSelector) ? class_getMethodImplementation(cls, originalSelector) : NULL;
            
            Method method = class_getInstanceMethod(cls, originalSelector);
            char *typeDescription = (char *)method_getTypeEncoding(method);
            
            class_replaceMethod(cls, selector, originalImp, typeDescription);
        }
        
        char *typeDescription = (char *)method_getTypeEncoding(class_getInstanceMethod(cls, @selector(forwardInvocation:)));
        IMP forwardInvocationIMP = class_getMethodImplementation(cls, @selector(ORIGforwardInvocation:));
        
        //forwardInvocationIMP will be _objc_msgForward if ORIGforwardInvocation: doesn't exist
        if (forwardInvocationIMP == _objc_msgForward) {
            class_replaceMethod(cls, @selector(forwardInvocation:), NULL, typeDescription);
        } else {
            class_replaceMethod(cls, @selector(forwardInvocation:), forwardInvocationIMP, typeDescription);
        }
    }
}

#pragma clang diagnostic pop
@end
