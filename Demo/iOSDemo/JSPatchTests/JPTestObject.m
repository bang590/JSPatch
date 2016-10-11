//
//  JPTestObject.m
//  InstaScript
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "JPTestObject.h"
#import <objc/runtime.h>

@implementation JPTestObject
- (void)funcReturnVoid
{
    self.funcReturnVoidPassed = YES;
}

- (NSString *)funcReturnString
{
    return @"stringFromOC";
}

- (double)funcReturnDouble {
    return 100.0;
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

- (void)funcWithNil:(NSObject *)nilObj
{
    self.funcWithNilPassed = nilObj == nil;
}

- (id)funcReturnNil
{
    return nil;
}

- (BOOL)funcTestBool:(BOOL)b
{
    return b;
}

- (NSNumber *)funcTestNSNumber:(NSNumber *)num
{
    return num;
}

- (void)funcWithNil:(NSObject *)nilObj dict:(NSDictionary *)dict str:(NSString *)str num:(double)num
{
    self.funcWithNilAndOthersPassed = nilObj == nil && [dict[@"k"] isEqualToString:@"JSPatch"] && [str isEqualToString:@"JSPatch"] && num - 4.2 < 0.001;
}
- (void)funcWithNull:(NSNull *)nullObj
{
    self.funcWithNullPassed = [nullObj isKindOfClass:[NSNull class]];
}

#pragma mark - NSDictionary / NSArray

- (void)funcWithDict:(NSDictionary *)dict andDouble:(double)doubleValue
{
    BOOL dictPass = [dict[@"test"] isEqualToString:@"test"];
    BOOL doublePass = doubleValue - 4.2 < 0.001;
    self.funcWithDictAndDoublePassed = dictPass && doublePass;
}

- (NSDictionary *)funcReturnDict:(NSDictionary *)dict
{
    return dict;
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

- (NSString *)getString
{
    return @"JSPatch";
}

- (NSArray *)getArray
{
    return @[@"JSPatch", @(1)];
}

- (NSDictionary *)getDictionary
{
    return @{@"k": @"JSPatch"};
}

- (void)funcTestBoxingObj:(NSArray *)data
{
    NSString *str = data[0];
    NSDictionary *dict = data[1];
    NSArray *arr = data[2];
    self.testBoxingObjPassed = [str isEqualToString:[self getString]] && [dict[@"k"] isEqualToString:[[self getDictionary] objectForKey:@"k"]] && [arr[0] isEqualToString:[[self getArray] objectAtIndex:0]];
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

typedef id (^JPTestObjectBlock)(NSDictionary *dict, UIView *view);
- (JPTestObjectBlock)funcReturnObjectBlock
{
    JPTestObjectBlock block = ^(NSDictionary *dict, UIView *view) {
        self.funcReturnObjectBlockPassed = [dict[@"str"] isEqualToString:@"stringFromJS"] && [dict[@"view"] isKindOfClass:[UIView class]] && view.frame.size.width == 100;
        return @"succ";
    };
    return block;
}

- (void)callBlockWithStringAndInt:(id(^)(NSString *str, int num))block
{
    id ret = block(@"stringFromOC", 42);
    self.callBlockWithStringAndIntReturnValuePassed = [ret isEqualToString:@"succ"];
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
    JPTestObjectBlock cbBlock = ^id(NSDictionary *dict, UIView *view) {
        self.callBlockWithObjectAndBlockPassed = [dict[@"str"] isEqualToString:@"stringFromJS"] && [dict[@"view"] isKindOfClass:[UIView class]] && view.frame.size.width == 100;
        return @"succ";
    };
    block(view, cbBlock);
}

#pragma mark - swizzle

typedef struct {
    char *name;
    int idx;
}JPTestStruct;

- (void)callSwizzleMethod
{
    [self funcToSwizzleWithString:@"stringFromOC" view:[[UIView alloc] init] int:42];
    [self funcToSwizzle:4.2 view:[[UIView alloc] init]];
    UIView *view = [self funcToSwizzleReturnView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)]];
    self.funcToSwizzleReturnViewPassed = view.frame.size.width == 100;
    
    UIView *nilView = [self funcToSwizzleReturnView:nil];
    self.funcToSwizzleParamNilPassed = !nilView;

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
    
    double retD = [JPTestObject classFuncToSwizzleReturnDouble:100.0];
    if (fabs(retD - 100.0) < FLT_EPSILON) {
        self.classFuncToSwizzleReturnDoublePassed = YES;
    }
    
    [self funcToSwizzleWithBlock:^(UIView *view, int num) {
        self.funcToSwizzleWithBlockPassed = view && num == 42;
    }];
    
    [self funcToSwizzle_withUnderLine_:42];
    
    CGRect rect = [self funcToSwizzleReturnRect:CGRectMake(0, 0, 100, 100)];
    self.funcToSwizzleReturnRectPassed = rect.size.width == 100;
    
    CGPoint point = [self funcToSwizzleReturnPoint:CGPointMake(42, 42)];
    self.funcToSwizzleReturnPointPassed = point.x == 42;
    
    CGSize size = [self funcToSwizzleReturnSize:CGSizeMake(42, 42)];
    self.funcToSwizzleReturnSizePassed = size.width == 42;
    
    NSRange range = [self funcToSwizzleReturnRange:NSMakeRange(0, 42)];
    self.funcToSwizzleReturnRangePassed = range.length == 42;
    
    UIEdgeInsets edgeInsets = [self funcToSwizzleReturnEdgeInsets:UIEdgeInsetsMake(42, 42, 0, 0)];
    self.funcToSwizzleReturnEdgeInsetsPassed = edgeInsets.left == 42;
    
    SEL selector = [self funcToSwizzleTestSelector:@selector(funcToSwizzleTestSelector:)];
    self.funcToSwizzleTestSelectorPassed = [NSStringFromSelector(selector) isEqualToString:@"funcToSwizzleTestSelector:"];
    
    char *cStr = [self funcToSwizzleTestChar:"JSPatch"];
    self.funcToSwizzleTestCharPassed = strcmp("JSPatch", cStr) == 0;
    
    JPTestStruct *testStruct = (JPTestStruct*)malloc(sizeof(JPTestStruct));
    testStruct->idx = 42;
    testStruct->name = "JSPatch";
    
    JPTestStruct *testStructReturn = [self funcToSwizzleTestPointer:testStruct];
    self.funcToSwizzleTestPointerPassed = testStructReturn->idx == 42 && strcmp(testStructReturn->name, "JSPatch") == 0;
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

- (NSDictionary *)funcToSwizzleReturnDictionary:(NSDictionary *)dict
{
    return nil;
}

- (NSDictionary *)funcToSwizzleReturnJSDictionary
{
    return nil;
}

- (NSArray *)funcToSwizzleReturnArray:(NSArray *)arr
{
    return nil;
}

- (NSString *)funcToSwizzleReturnString:(NSString *)str
{
    return nil;
}

- (void)funcToSwizzleWithBlock:(void(^)(UIView *view, int num))block
{

}

- (void)funcToSwizzle_withUnderLine_:(int)num
{
    
}

- (CGRect)funcToSwizzleReturnRect:(CGRect)rect
{
    return CGRectZero;
}
- (CGPoint)funcToSwizzleReturnPoint:(CGPoint)point
{
    return CGPointZero;
}
- (CGSize)funcToSwizzleReturnSize:(CGSize)size
{
    return CGSizeZero;
}
- (NSRange)funcToSwizzleReturnRange:(NSRange)range
{
    return NSMakeRange(0, 0);
}
- (UIEdgeInsets)funcToSwizzleReturnEdgeInsets:(UIEdgeInsets)edgeInsets
{
    return UIEdgeInsetsZero;
}

- (void)funcToSwizzleTestGCD:(void(^)())block
{
    
}

- (Class)funcToSwizzleTestClass:(Class)cls
{
    return nil;
}

- (SEL)funcToSwizzleTestSelector:(SEL)selector
{
    return nil;
}

- (char *)funcToSwizzleTestChar:(char *)cStr
{
    return NULL;
}

- (char *)funcReturnChar
{
    return "JSPatch";
}

- (void)funcTestChar:(char *)cStr
{
    self.funcTestCharPassed = strcmp("JSPatch", cStr) == 0;
}

- (void *)funcToSwizzleTestPointer:(void *)pointer
{
    return NULL;
}

- (BOOL)funcTestNSErrorPointer:(NSError **)error
{
    NSError *tmp = [[NSError alloc]initWithDomain:@"com.albert43" code:43 userInfo:@{@"msg":@"test error"}];
    if (error)
        *error = tmp;
    
    return NO;
}

- (void *)funcReturnPointer
{
    JPTestStruct *testStruct = (JPTestStruct*)malloc(sizeof(JPTestStruct));
    testStruct->idx = 42;
    testStruct->name = "JSPatch";
    return testStruct;
}

- (void)funcTestPointer:(void *)pointer
{
    JPTestStruct *testStruct = pointer;
    self.funcTestPointerPassed = testStruct->idx == 42 && strcmp(testStruct->name, "JSPatch") == 0;
}

- (BOOL)funcTestGetPointer1:(NSString *)str
{
    if ([str isEqualToString:@"JSPatch"]) {
        return YES;
    }
    return NO;
}

- (BOOL)funcTestGetPointer2:(NSError *)error
{
    if ([[[error userInfo] description] isEqualToString:[@{@"msg":@"test"} description]]) {
        return YES;
    }
    return NO;
}

- (BOOL)funcTestGetPointer3:(void *)arr
{
    char *p = arr;
    for (int i = 0; i < 10; i++) {
        if (p[i] != 'A') {
            return false;
        }
    }
    return true;
}

typedef NSString * (^JSBlock)(NSError *);
- (JSBlock)funcGenerateBlock {
    JSBlock block = ^(NSError *err) {
        if (err) {
            return [err description];
        }else {
            return @"no error";
        }
    };
    return block;
}

- (NSString *)excuteBlockWithNilParameters:(JSBlock)blk {
    if (blk) {
        return blk(nil);
    }
    return nil;
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

+ (double)classFuncToSwizzleReturnDouble:(double)d
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


#pragma mark -
- (NSString*)funcOverrideParentMethod
{
    return @"orgi";
}

#pragma mark CGAffineTransform
- (CGAffineTransform)funcWithTransform:(CGAffineTransform)transform
{
    return transform;
}

#pragma mark structPointer
- (void)funcWithRectPointer:(CGRect *)rect
{
    self.funcWithRectPointerPassed = rect->size.width == 100;
    rect->origin.x = 42;
}
- (void)funcWithTransformPointer:(CGAffineTransform *)transform
{
    self.funcWithTransformPointerPassed = transform->a == 100;
    transform->tx = 42;
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation JPTestProtocolObject
- (BOOL)testProtocolMethods
{
    double dNum = [self protocolWithDouble:4.2 dict:@{@"name": @"JSPatch"}];
    NSInteger iNum = [self protocolWithInt:42];
    NSString *str = [JPTestProtocolObject classProtocolWithString:@"JSPatch" int:42];
    return dNum - 4.2 < 0.001 && iNum == 42 && [str isEqualToString:@"JSPatch"];
}
#pragma clang diagnostic pop
@end

@implementation JPTestSwizzledForwardInvocationSuperObject

- (void)swizzleSuperForwoardInvocation
{
    class_replaceMethod([JPTestSwizzledForwardInvocationSuperObject class], @selector(forwardInvocation:), (IMP)SwizzledSuperForwardInvocation, "v@:@");
}

static void SwizzledSuperForwardInvocation(__unsafe_unretained id assignSlf, SEL selector, NSInvocation *invocation)
{
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"testSwizzledSuperForwardInvocation"]) {
        ((JPTestSwizzledForwardInvocationSuperObject *)assignSlf).callSwizzledSuperForwardInvocationPassed = YES;
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([NSStringFromSelector(anInvocation.selector) isEqualToString:@"testSwizzledSuperForwardInvocation"]) {
        self.callSwizzledSuperForwardInvocationPassed = NO;
    }
}

@end

@implementation JPTestSwizzledForwardInvocationSubObject

- (void)callTestSwizzledSuperForwardInvocation
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(testSwizzledSuperForwardInvocation) withObject:nil];
#pragma clang diagnostic pop
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) isEqualToString:@"testSwizzledSuperForwardInvocation"]) {
        return [self methodSignatureForSelector:@selector(callTestSwizzledSuperForwardInvocation)];
    }
    return [super methodSignatureForSelector:aSelector];
}

@end
