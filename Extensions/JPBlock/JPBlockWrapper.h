//
//  JPBlockWrapper.h
//  JSPatch
//
//  Created by bang on 1/19/17.
//  Copyright © 2017 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JPBlockWrapper : NSObject;
- (void *)blockPtr;
- (id)initWithTypeString:(NSString *)typeString callbackFunction:(JSValue *)jsFunction;
@end
