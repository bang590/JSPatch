//
//  ISTestObject.h
//  InstaScript
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JPTestObject : NSObject
- (void)funcWithInt:(int)intValue;
@property (nonatomic, assign) BOOL funcReturnVoidPassed;
@property (nonatomic, assign) BOOL funcReturnStringPassed;
@property (nonatomic, assign) BOOL funcReturnViewWithFramePassed;
@property (nonatomic, assign) BOOL funcWithViewAndReturnViewPassed;

@property (nonatomic, assign) BOOL funcWithIntPassed;
@property (nonatomic, assign) BOOL funcWithDictAndDoublePassed;

@property (nonatomic, assign) BOOL funcWithRangeAndReturnRangePassed;
@property (nonatomic, assign) BOOL funcWithRectAndReturnRectPassed;
@property (nonatomic, assign) BOOL funcWithPointAndReturnPointPassed;
@property (nonatomic, assign) BOOL funcWithSizeAndReturnSizePassed;

@property (nonatomic, assign) BOOL funcReturnDictStringIntPassed;
@property (nonatomic, assign) BOOL funcReturnDictStringViewPassed;
@property (nonatomic, assign) BOOL funcReturnArrayControllerViewStringPassed;
@property (nonatomic, assign) BOOL funcReturnDictPassed;

@property (nonatomic, assign) BOOL funcReturnBlockPassed;
@property (nonatomic, assign) BOOL funcReturnObjectBlockPassed;
@property (nonatomic, assign) BOOL callBlockWithStringAndIntPassed;
@property (nonatomic, assign) BOOL callBlockWithArrayAndViewPassed;
@property (nonatomic, assign) BOOL callBlockWithBoolAndBlockPassed;
@property (nonatomic, assign) BOOL callBlockWithObjectAndBlockPassed;


@property (nonatomic, assign) BOOL funcToSwizzleWithStringViewIntPassed;
@property (nonatomic, assign) BOOL funcToSwizzleViewPassed;
@property (nonatomic, assign) BOOL funcToSwizzleViewCalledOriginalPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnViewPassed;
@property (nonatomic, assign) BOOL funcToSwizzleParamNilPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnIntPassed;
@property (nonatomic, assign) BOOL funcToSwizzleWithBlockPassed;
@property (nonatomic, assign) BOOL funcToSwizzle_withUnderLine_Passed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnRectPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnPointPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnSizePassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnRangePassed;
@property (nonatomic, assign) BOOL classFuncToSwizzlePassed;
@property (nonatomic, assign) BOOL classFuncToSwizzleReturnObjPassed;
@property (nonatomic, assign) BOOL classFuncToSwizzleReturnObjCalledOriginalPassed;
@property (nonatomic, assign) BOOL classFuncToSwizzleReturnIntPassed;
@property (nonatomic, assign) BOOL callCustomFuncPassed;


@property (nonatomic, assign) BOOL funcCallSuperPassed;
@property (nonatomic, assign) BOOL callForwardInvocationPassed;

@property (nonatomic, strong) UIView *testView;
@property (nonatomic, assign) BOOL propertySetFramePassed;
@property (nonatomic, assign) BOOL propertySetViewPassed;

@property (nonatomic, assign) BOOL newTestObjectReturnViewPassed;
@property (nonatomic, assign) BOOL newTestObjectReturnBoolPassed;
@property (nonatomic, assign) BOOL newTestObjectCustomFuncPassed;

@property (nonatomic, assign) BOOL consoleLogPassed;
@property (nonatomic, assign) BOOL overrideParentMethodPassed;

- (NSString*)funcOverrideParentMethod;

@end


@interface JPTestSubObject : JPTestObject
@property (nonatomic, assign) BOOL funcCallSuperSubObjectPassed;
@end