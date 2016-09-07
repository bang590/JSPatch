//
//  ISTestObject.h
//  InstaScript
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JPTestObject : NSObject
- (void)funcWithInt:(int)intValue;
@property (nonatomic, assign) BOOL funcReturnVoidPassed;
@property (nonatomic, assign) BOOL funcReturnStringPassed;
@property (nonatomic, assign) BOOL funcReturnDoublePassed;
@property (nonatomic, assign) BOOL funcReturnViewWithFramePassed;
@property (nonatomic, assign) BOOL funcWithViewAndReturnViewPassed;

@property (nonatomic, assign) BOOL funcWithIntPassed;
@property (nonatomic, assign) BOOL funcWithNilPassed;
@property (nonatomic, assign) BOOL funcReturnNilPassed;
@property (nonatomic, assign) BOOL funcWithNilAndOthersPassed;
@property (nonatomic, assign) BOOL funcWithNullPassed;
@property (nonatomic, assign) BOOL funcTestBoolPassed;
@property (nonatomic, assign) BOOL funcTestNSNumberPassed;


@property (nonatomic, assign) BOOL funcWithDictAndDoublePassed;

@property (nonatomic, assign) BOOL funcWithRangeAndReturnRangePassed;
@property (nonatomic, assign) BOOL funcWithRectAndReturnRectPassed;
@property (nonatomic, assign) BOOL funcWithPointAndReturnPointPassed;
@property (nonatomic, assign) BOOL funcWithSizeAndReturnSizePassed;

@property (nonatomic, assign) BOOL funcReturnDictStringIntPassed;
@property (nonatomic, assign) BOOL funcReturnDictStringViewPassed;
@property (nonatomic, assign) BOOL funcReturnArrayControllerViewStringPassed;
@property (nonatomic, assign) BOOL funcReturnDictPassed;
@property (nonatomic, assign) BOOL testBoxingObjPassed;

@property (nonatomic, assign) BOOL funcReturnBlockPassed;
@property (nonatomic, assign) BOOL funcReturnObjectBlockPassed;
@property (nonatomic, assign) BOOL funcReturnObjectBlockReturnValuePassed;
@property (nonatomic, assign) BOOL callBlockWithStringAndIntPassed;
@property (nonatomic, assign) BOOL callBlockWithStringAndIntReturnValuePassed;
@property (nonatomic, assign) BOOL callBlockWithArrayAndViewPassed;
@property (nonatomic, assign) BOOL callBlockWithBoolAndBlockPassed;
@property (nonatomic, assign) BOOL callBlockWithObjectAndBlockPassed;
@property (nonatomic, assign) BOOL callBlockWithObjectAndBlockReturnValuePassed;


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
@property (nonatomic, assign) BOOL funcToSwizzleReturnEdgeInsetsPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnRectJSPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnPointJSPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnSizeJSPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnRangeJSPassed;
@property (nonatomic, assign) BOOL funcToSwizzleReturnEdgeInsetsJSPassed;
@property (nonatomic, assign) BOOL funcToSwizzleTestGCDPassed;
@property (nonatomic, assign) BOOL funcToSwizzleTestClassPassed;
@property (nonatomic, assign) BOOL funcToSwizzleTestSelectorPassed;
@property (nonatomic, assign) BOOL funcToSwizzleTestCharPassed;
@property (nonatomic, assign) BOOL funcTestCharPassed;
@property (nonatomic, assign) BOOL funcToSwizzleTestPointerPassed;
@property (nonatomic, assign) BOOL funcTestPointerPassed;
@property (nonatomic, assign) BOOL funcTestSizeofPassed;
@property (nonatomic, assign) BOOL funcTestGetPointerPassed;
@property (nonatomic, assign) BOOL funcTestNSErrorPointerPassed;
@property (nonatomic, assign) BOOL funcTestNilParametersInBlockPassed;
@property (nonatomic, assign) BOOL classFuncToSwizzlePassed;
@property (nonatomic, assign) BOOL classFuncToSwizzleReturnObjPassed;
@property (nonatomic, assign) BOOL classFuncToSwizzleReturnObjCalledOriginalPassed;
@property (nonatomic, assign) BOOL classFuncToSwizzleReturnIntPassed;
@property (nonatomic, assign) BOOL classFuncToSwizzleReturnDoublePassed;


@property (nonatomic, assign) BOOL funcCallSuperPassed;
@property (nonatomic, assign) BOOL callForwardInvocationPassed;

@property (nonatomic, strong) UIView *testView;
@property (nonatomic, assign) BOOL propertySetFramePassed;
@property (nonatomic, assign) BOOL propertySetViewPassed;

@property (nonatomic, assign) BOOL newTestObjectReturnViewPassed;
@property (nonatomic, assign) BOOL newTestObjectReturnBoolPassed;
@property (nonatomic, assign) BOOL newTestObjectCustomFuncPassed;

@property (nonatomic, assign) BOOL mutableArrayPassed;
@property (nonatomic, assign) BOOL mutableStringPassed;
@property (nonatomic, assign) BOOL mutableDictionaryPassed;

@property (nonatomic, assign) BOOL funcWithTransformPassed;
@property (nonatomic, assign) BOOL transformTranslatePassed;
@property (nonatomic, assign) BOOL funcWithRectPointerPassed;
@property (nonatomic, assign) BOOL funcWithTransformPointerPassed;

@property (nonatomic, assign) BOOL consoleLogPassed;
@property (nonatomic, assign) BOOL overrideParentMethodPassed;

@property (nonatomic, assign) BOOL variableParameterMethodPassed;

- (NSString*)funcOverrideParentMethod;
- (void)funcToSwizzleTestGCD:(void(^)())block;

- (NSDictionary *)funcToSwizzleReturnDictionary:(NSDictionary *)dict;
- (NSDictionary *)funcToSwizzleReturnJSDictionary;
- (NSArray *)funcToSwizzleReturnArray:(NSArray *)arr;
- (NSString *)funcToSwizzleReturnString:(NSString *)str;
@end


@interface JPTestSubObject : JPTestObject
@property (nonatomic, assign) BOOL funcCallSuperSubObjectPassed;
@end

@protocol JPTestProtocol <NSObject>
- (double)protocolWithDouble:(double)num dict:(NSDictionary *)dictionary;
+ (NSString *)classProtocolWithString:(NSString *)string int:(NSInteger)num;
@end

@protocol JPTestProtocol2 <NSObject>
@optional
- (NSInteger)protocolWithInt:(NSInteger)num;
@end

@interface JPTestProtocolObject : NSObject <JPTestProtocol, JPTestProtocol2>
- (BOOL)testProtocolMethods;
@end

@interface JPTestSwizzledForwardInvocationSuperObject : NSObject

@property (nonatomic, assign) BOOL callSwizzledSuperForwardInvocationPassed;

- (void)swizzleSuperForwoardInvocation;

@end

@interface JPTestSwizzledForwardInvocationSubObject : JPTestSwizzledForwardInvocationSuperObject

- (void)callTestSwizzledSuperForwardInvocation;

@end
