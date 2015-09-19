//
//  JPIVar.h
//  JSPatchDemo
//
//  Created by liang on 9/19/15.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPIVar : NSObject

/**
 * Reads the value of an instance variable in an object.
 *
 * @param obj The object containing the instance variable whose value you want to read.
 * @param name The name describing the instance variable whose value you want to read.
 *
 * @return The value of the instance variable specified by \e name, or \c nil if \e object is \c nil.
 *
 */
+ (id)getIvarOfObject:(id)object name:(NSString *)name;

/**
 * Sets the value of an instance variable in an object.
 *
 * @param obj The object containing the instance variable whose value you want to set.
 * @param name The name describing the instance variable whose value you want to set.
 * @param value The new value for the instance variable.
 */
+ (void)setIvarOfObject:(id)object name:(NSString *)name value:(id)value;

@end
