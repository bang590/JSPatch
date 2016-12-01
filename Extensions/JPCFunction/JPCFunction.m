//
//  JPCFunction.m
//  JSPatchDemo
//
//  Created by bang on 5/30/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPCFunction.h"
#import "ffi.h"
#import <dlfcn.h>

@interface JPCFunctionSignature : NSObject
@property (nonatomic, readonly) NSArray *argumentTypes;
@property (nonatomic, readonly) NSString *returnType;
@end

@implementation JPCFunctionSignature {
    NSString *_encodingString;
    NSMutableArray *_argumentTypes;
}

- (instancetype)initWithEncodingString:(NSString *)encodingString
{
    self = [super init];
    if (self) {
        _encodingString = encodingString;
        [self _parse];
    }
    return self;
}

- (void)_parse
{
    _argumentTypes = [[NSMutableArray alloc] init];
    for (int i = 0; i < _encodingString.length; i ++) {
        unichar c = [_encodingString characterAtIndex:i];
        NSString *arg;
        BOOL isPointer = NO;
        if (c == '^') {
            isPointer = YES;
            arg = [_encodingString substringWithRange:NSMakeRange(i, 2)];
        } else {
            arg = [_encodingString substringWithRange:NSMakeRange(i, 1)];
        }
        if (i == 0) {
            _returnType = arg;
        } else {
            [_argumentTypes addObject:arg];
        }
        if (isPointer) i++;
    }
}

- (NSArray *)argumentTypes
{
    return _argumentTypes;
}

- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx
{
    return [_argumentTypes[idx] UTF8String];
}

+ (ffi_type *)ffiTypeWithEncodingChar:(const char *)c
{
    switch (c[0]) {
        case 'v':
            return &ffi_type_void;
        case 'c':
            return &ffi_type_schar;
        case 'C':
            return &ffi_type_uchar;
        case 's':
            return &ffi_type_sshort;
        case 'S':
            return &ffi_type_ushort;
        case 'i':
            return &ffi_type_sint;
        case 'I':
            return &ffi_type_uint;
        case 'l':
            return &ffi_type_slong;
        case 'L':
            return &ffi_type_ulong;
        case 'q':
            return &ffi_type_sint64;
        case 'Q':
            return &ffi_type_uint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'B':
            return &ffi_type_uint8;
        case '^':
            return &ffi_type_pointer;
        case '@':
            return &ffi_type_pointer;
        case '#':
            return &ffi_type_pointer;
    }
    return NULL;
}

@end




@implementation JPCFunction

static NSMutableDictionary *_funcDefines;
static NSMutableDictionary *_typeEncodeDict;

+ (void)main:(JSContext *)context
{
    if (!_funcDefines) {
        _funcDefines = [[NSMutableDictionary alloc] init];
    }
    
    [context evaluateScript:@"  \
     global.defineCFunction = function(funcName, paramsStr) {   \
         _OC_defineCFunction(funcName, paramsStr);   \
         global[funcName] = function() {    \
             var args = Array.prototype.slice.call(arguments);   \
             return _OC_callCFunc.apply(global, [funcName, args]);   \
         }  \
     }  \
     "];
    
    context[@"_OC_defineCFunction"] = ^void(NSString *funcName, NSString *types) {
        [self defineCFunction:funcName types:types];
    };
    
    context[@"_OC_callCFunc"] = ^id(NSString *funcName, JSValue *args) {
        id ret = [self callCFunction:funcName arguments:[self formatJSToOC:args]];
        return [self formatOCToJS:ret];
    };
}

+ (void)defineCFunction:(NSString *)funcName types:(NSString *)types
{
    if (!_typeEncodeDict) {
        _typeEncodeDict = [[NSMutableDictionary alloc] init];
#define JP_DEFINE_TYPE_ENCODE_CASE(_type) \
        [_typeEncodeDict setObject:[NSString stringWithUTF8String:@encode(_type)] forKey:@#_type];\

        JP_DEFINE_TYPE_ENCODE_CASE(id);
        JP_DEFINE_TYPE_ENCODE_CASE(BOOL);
        JP_DEFINE_TYPE_ENCODE_CASE(int);
        JP_DEFINE_TYPE_ENCODE_CASE(void);
        JP_DEFINE_TYPE_ENCODE_CASE(char);
        JP_DEFINE_TYPE_ENCODE_CASE(short);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned short);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned int);
        JP_DEFINE_TYPE_ENCODE_CASE(long);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned long);
        JP_DEFINE_TYPE_ENCODE_CASE(long long);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned long long);
        JP_DEFINE_TYPE_ENCODE_CASE(float);
        JP_DEFINE_TYPE_ENCODE_CASE(double);
        JP_DEFINE_TYPE_ENCODE_CASE(bool);
        JP_DEFINE_TYPE_ENCODE_CASE(size_t);
        JP_DEFINE_TYPE_ENCODE_CASE(CGFloat);
        JP_DEFINE_TYPE_ENCODE_CASE(CGSize);
        JP_DEFINE_TYPE_ENCODE_CASE(CGRect);
        JP_DEFINE_TYPE_ENCODE_CASE(CGPoint);
        JP_DEFINE_TYPE_ENCODE_CASE(CGVector);
        JP_DEFINE_TYPE_ENCODE_CASE(NSRange);
        JP_DEFINE_TYPE_ENCODE_CASE(NSInteger);
        JP_DEFINE_TYPE_ENCODE_CASE(Class);
        JP_DEFINE_TYPE_ENCODE_CASE(SEL);
        JP_DEFINE_TYPE_ENCODE_CASE(void*);
        JP_DEFINE_TYPE_ENCODE_CASE(void *);
        [_typeEncodeDict setObject:@"@?" forKey:@"block"];
        [_typeEncodeDict setObject:@"^@" forKey:@"id*"];
    }
    
    NSMutableString *encodeStr = [[NSMutableString alloc] init];
    NSArray *typeArr = [types componentsSeparatedByString:@","];
    for (NSInteger i = 0; i < typeArr.count; i++) {
        NSString *typeStr = trim([typeArr objectAtIndex:i]);
        NSString *encode = _typeEncodeDict[typeStr];
        if (!encode) {
            NSString *argClassName = trim([typeStr stringByReplacingOccurrencesOfString:@"*" withString:@""]);
            if (NSClassFromString(argClassName) != NULL) {
                encode = @"@";
            } else {
                NSCAssert(NO, @"unreconized type %@", typeStr);
                return;
            }
        }
        [encodeStr appendString:encode];
    }
    [_funcDefines setObject:encodeStr forKey:funcName];
}

+ (id)callCFunction:(NSString *)funcName arguments:(NSArray *)arguments
{
    void* functionPtr = dlsym(RTLD_DEFAULT, [funcName UTF8String]);
    if (!functionPtr) {
        return nil;
    }
    
    JPCFunctionSignature *funcSignature = [[JPCFunctionSignature alloc] initWithEncodingString:[_funcDefines objectForKey:funcName]];
    
    NSUInteger argCount = funcSignature.argumentTypes.count;
    if (argCount != [arguments count]){
        return nil;
    }
    
    ffi_type **ffiArgTypes = alloca(sizeof(ffi_type *) *argCount);
    void **ffiArgs = alloca(sizeof(void *) *argCount);
    for (int i = 0; i < argCount; i ++) {
        const char *argumentType = [funcSignature getArgumentTypeAtIndex:i];
        ffi_type *ffiType = [JPCFunctionSignature ffiTypeWithEncodingChar:argumentType];
        ffiArgTypes[i] = ffiType;
        size_t typeSize = ffiType->size;
        void *ffiArgPtr = alloca(typeSize);
        
        switch (argumentType[0]) {
        #define JP_CALL_ARG_CASE(_typeString, _type, _selector) \
            case _typeString: {                              \
                _type *argPtr = ffiArgPtr;                     \
                *argPtr = [(NSNumber *)arguments[i] _selector];\
                break; \
            }
            
            JP_CALL_ARG_CASE('c', char, charValue)
            JP_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
            JP_CALL_ARG_CASE('s', short, shortValue)
            JP_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
            JP_CALL_ARG_CASE('i', int, intValue)
            JP_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
            JP_CALL_ARG_CASE('l', long, longValue)
            JP_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
            JP_CALL_ARG_CASE('q', long long, longLongValue)
            JP_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
            JP_CALL_ARG_CASE('f', float, floatValue)
            JP_CALL_ARG_CASE('d', double, doubleValue)
            JP_CALL_ARG_CASE('B', BOOL, boolValue)
                
            case '^': {
                void *ptr = [((JPBoxing *)arguments[i]) unboxPointer];
                void **argPtr = ffiArgPtr;
                *argPtr = ptr;
                break;
            }
            case '#': {
                id ptr = arguments[i];
                void **argPtr = ffiArgPtr;
                *argPtr = (__bridge void *)(ptr);
                break;
            }
            case '@': {
                id ptr = arguments[i];
                void **argPtr = ffiArgPtr;
                *argPtr = (__bridge void *)(ptr);
                break;
            }
        }
        ffiArgs[i] = ffiArgPtr;
    }
    
    
    ffi_cif cif;
    id ret = nil;
    const char *returnTypeChar = [funcSignature.returnType UTF8String];
    ffi_type *returnFfiType = [JPCFunctionSignature ffiTypeWithEncodingChar:returnTypeChar];
    ffi_status ffiPrepStatus = ffi_prep_cif_var(&cif, FFI_DEFAULT_ABI, (unsigned int)0, (unsigned int)argCount, returnFfiType, ffiArgTypes);
    
    if (ffiPrepStatus == FFI_OK) {
        void *returnPtr = NULL;
        if (returnFfiType->size) {
            returnPtr = alloca(returnFfiType->size);
        }
        ffi_call(&cif, functionPtr, returnPtr, ffiArgs);
        if (returnFfiType->size) {
            switch (returnTypeChar[0]) {
            #define JP_FFI_RETURN_CASE(_typeString, _type, _selector) \
                case _typeString: {                              \
                    _type returnValue = *(_type *)returnPtr;                     \
                    ret = [NSNumber _selector:returnValue];\
                    break; \
                }
                JP_FFI_RETURN_CASE('c', char, numberWithChar)
                JP_FFI_RETURN_CASE('C', unsigned char, numberWithUnsignedChar)
                JP_FFI_RETURN_CASE('s', short, numberWithShort)
                JP_FFI_RETURN_CASE('S', unsigned short, numberWithUnsignedShort)
                JP_FFI_RETURN_CASE('i', int, numberWithInt)
                JP_FFI_RETURN_CASE('I', unsigned int, numberWithUnsignedInt)
                JP_FFI_RETURN_CASE('l', long, numberWithLong)
                JP_FFI_RETURN_CASE('L', unsigned long, numberWithUnsignedLong)
                JP_FFI_RETURN_CASE('q', long long, numberWithLongLong)
                JP_FFI_RETURN_CASE('Q', unsigned long long, numberWithUnsignedLongLong)
                JP_FFI_RETURN_CASE('f', float, numberWithFloat)
                JP_FFI_RETURN_CASE('d', double, numberWithDouble)
                JP_FFI_RETURN_CASE('B', BOOL, numberWithBool)
                    
                case '@': {
                    ret = (__bridge id)(*(void**)returnPtr);
                    break;
                }
                case '^': {
                    JPBoxing *box = [[JPBoxing alloc] init];
                    box.pointer = (*(void**)returnPtr);
                    ret = box;
                    break;
                }
                case '#': {
                    ret = (__bridge id)(*(void**)returnPtr);
                    break;
                }
            }
        }
    }
    
    return ret;
}

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
