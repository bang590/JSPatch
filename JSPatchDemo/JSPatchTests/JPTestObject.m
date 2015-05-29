//
//  JPTestObject.m
//  InstaScript
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPTestObject.h"

@implementation JPTestObject
- (void)funcReturnVoid
{
    self.funcReturnVoidPassed = YES;
}

- (NSString *)funcReturnString
{
    return @"stringFromOC";
}

- (CGRect)funcWithRectAndReturnRect:(CGRect)rect
{
    return rect;
}

- (CGPoint)funcWithPointAndReturnPoint:(CGPoint)point
{
    return point;
}

- (CGSize)funcWithSizeAndReturnSize:(CGSize)size
{
    return size;
}

- (NSRange)funcWithRangeAndReturnRange:(NSRange)range
{
    return range;
}

- (UIView *)funcReturnViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    return view;
}

- (UIView *)funcWithViewAndReturnView:(UIView *)view
{
    return view;
}

- (void)funcWithInt:(int)intValue
{
    self.funcWithIntPassed = intValue == 42;
}

#pragma mark - NSDictionary / NSArray

- (void)funcWithDict:(NSDictionary *)dict andDouble:(double)doubleValue
{
    BOOL dictPass = [dict[@"test"] isEqualToString:@"test"];
    BOOL doublePass = doubleValue - 4.2 < 0.001;
    self.funcWithDictAndDoublePassed = dictPass && doublePass;
}

- (NSDictionary *)funcReturnDictStringInt
{
    return @{@"str": @"stringFromOC", @"num": @(42)};
}

- (NSDictionary *)funcReturnDictStringView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    return @{@"view": view, @"str": @"stringFromOC"};
}

- (NSArray *)funcReturnArrayControllerViewString
{
    UIViewController *controller = [[UIViewController alloc] init];
    UIView *view = [[UIView alloc] init];
    return @[controller, view, @"stringFromOC"];
}


#pragma mark - block

typedef void (^ISTestBlock)(NSString *str, int num);
- (ISTestBlock)funcReturnBlock
{
    ISTestBlock block = ^(NSString *str, int num) {
        self.funcReturnBlockPassed = [str isEqualToString:@"stringFromJS"] && num == 42;
    };
    return block;
}

typedef void (^JPTestObjectBlock)(NSDictionary *dict, UIView *view);
- (JPTestObjectBlock)funcReturnObjectBlock
{
    JPTestObjectBlock block = ^(NSDictionary *dict, UIView *view) {
        self.funcReturnObjectBlockPassed = [dict[@"str"] isEqualToString:@"stringFromJS"] && [dict[@"view"] isKindOfClass:[UIView class]] && view.frame.size.width == 100;
    };
    return block;
}

- (void)callBlockWithStringAndInt:(void(^)(NSString *str, int num))block
{
    block(@"stringFromOC", 42);
}

- (void)callBlockWithArrayAndView:(void(^)(NSArray *arr, UIView *view))block
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    block(@[@"stringFromOC", view], view);
}

- (void)callBlockWithBoolAndBlock:(void(^)(BOOL b, ISTestBlock block))block
{
    ISTestBlock cbBlock = ^(NSString *str, int num) {
        self.callBlockWithBoolAndBlockPassed = [str isEqualToString:@"stringFromJS"] && num == 42;
    };
    block(YES, cbBlock);
}

- (void)callBlockWithObjectAndBlock:(void(^)(UIView *view, JPTestObjectBlock block))block
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    JPTestObjectBlock cbBlock = ^(NSDictionary *dict, UIView *view) {
        self.callBlockWithObjectAndBlockPassed = [dict[@"str"] isEqualToString:@"stringFromJS"] && [dict[@"view"] isKindOfClass:[UIView class]] && view.frame.size.width == 100;
    };
    block(view, cbBlock);
}

#pragma mark - swizzle
- (void)callSwizzleMethod
{
    [self funcToSwizzleWithString:@"stringFromOC" view:[[UIView alloc] init] int:42];
    [self funcToSwizzle:4.2 view:[[UIView alloc] init]];
    UIView *view = [self funcToSwizzleReturnView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)]];
    self.funcToSwizzleReturnViewPassed = view.frame.size.width == 100;
    
    int num = [self funcToSwizzleReturnInt:42];
    self.funcToSwizzleReturnIntPassed = num == 42;
    
    [JPTestObject classFuncToSwizzle:self int:10];
    id ret = [JPTestObject classFuncToSwizzleReturnObj:self];
    if ([ret isKindOfClass:[JPTestObject class]]) {
        self.classFuncToSwizzleReturnObjPassed = YES;
    }
    
    int retI = [JPTestObject classFuncToSwizzleReturnInt:42];
    if (retI == 42) {
        self.classFuncToSwizzleReturnIntPassed = YES;
    }
    
    [self funcToSwizzleWithBlock:^(UIView *view, int num) {
        self.funcToSwizzleWithBlockPassed = view && num == 42;
    }];
    
    [self funcToSwizzle_withUnderLine_:42];
    
}
- (void)funcToSwizzleWithString:(NSString *)str view:(UIView *)view int:(NSInteger)i
{
    self.funcToSwizzleWithStringViewIntPassed = NO;
}

- (void)funcToSwizzle:(double)num view:(UIView *)view
{
    self.funcToSwizzleViewCalledOriginalPassed = 4.2 - num< 0.01 && view;
}

- (UIView *)funcToSwizzleReturnView:(UIView *)view
{
    return nil;
}

- (int)funcToSwizzleReturnInt:(int)num
{
    return 0;
}

- (void)funcToSwizzleWithBlock:(void(^)(UIView *view, int num))block
{

}

- (void)funcToSwizzle_withUnderLine_:(int)num
{
    
}

+ (void)classFuncToSwizzle:(JPTestObject *)testObject int:(NSInteger)i
{
    
}

+ (id)classFuncToSwizzleReturnObj:(JPTestObject *)obj
{
    obj.classFuncToSwizzleReturnObjCalledOriginalPassed = YES;
    return nil;
}

+ (int)classFuncToSwizzleReturnInt:(int)i
{
    return 0;
}

#pragma mark - super
- (void)funcCallSuper
{
    self.funcCallSuperPassed = YES;
}

#pragma mark - performance
- (void)pFuncVoid
{
    
}
- (int)pFuncReturnInt
{
    return 42;
}
- (void)pFuncParamInt:(int)num
{
    
}
- (id)pFuncReturnSelf
{
    return self;
}
- (void)pFuncParamSelf:(id)obj
{
    
}


#pragma mark - forward
- (void)callTestForward
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(testForward) withObject:nil];
#pragma clang diagnostic pop
}
- (void)funcToForward
{
    self.callForwardInvocationPassed = YES;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([NSStringFromSelector(anInvocation.selector) isEqualToString:@"testForward"]) {
        [self funcToForward];
    }
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) isEqualToString:@"funcToSwizzleRect:"]) {
        NSLog(@"ss");
    }
    if ([NSStringFromSelector(aSelector) isEqualToString:@"testForward"]) {
        return [self methodSignatureForSelector:@selector(funcToForward)];
    }
    return [super methodSignatureForSelector:aSelector];
}

@end


@implementation JPTestSubObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.funcCallSuperSubObjectPassed = YES;
    }
    return self;
}
- (void)funcCallSuper
{
    self.funcCallSuperSubObjectPassed = NO;
}

@end
