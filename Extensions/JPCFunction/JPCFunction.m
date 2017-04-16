//
//  JPCFunction.m
//  JSPatch
//
//  Created by bang on 5/30/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPCFunction.h"
#import "ffi.h"
#import <dlfcn.h>
#import "JPMethodSignature.h"

#if CGFLOAT_IS_DOUBLE
#define CGFloatValue doubleValue
#define numberWithCGFloat numberWithDouble
#else
#define CGFloatValue floatValue
#define numberWithCGFloat numberWithFloat
#endif

@implementation JPCFunction

static NSMutableDictionary *_funcDefines;

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
    NSMutableString *encodeStr = [[NSMutableString alloc] init];
    NSArray *typeArr = [types componentsSeparatedByString:@","];
    for (NSInteger i = 0; i < typeArr.count; i++) {
        NSString *typeStr = trim([typeArr objectAtIndex:i]);
        NSString *encode = [JPMethodSignature typeEncodeWithTypeName:typeStr];
        if (!encode) {
            if ([typeStr hasPrefix:@"{"] && [typeStr hasSuffix:@"}"]) {
                encode = typeStr;
            } else {
                NSString *argClassName = trim([typeStr stringByReplacingOccurrencesOfString:@"*" withString:@""]);
                if (NSClassFromString(argClassName) != NULL) {
                    encode = @"@";
                } else {
                    NSCAssert(NO, @"unreconized type %@", typeStr);
                    return;
                }
            }
        }
        [encodeStr appendString:encode];
    }
    [_funcDefines setObject:encodeStr forKey:funcName];
}

+ (id)objectWithCValue:(void *)src forType:(const char *)typeString
{
    switch (typeString[0]) {
    #define JP_FFI_RETURN_CASE(_typeString, _type, _selector)\
        case _typeString:{\
            _type v = *(_type *)src;\
            return [NSNumber _selector:v];\
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
        JP_FFI_RETURN_CASE('F', CGFloat, numberWithCGFloat)
        JP_FFI_RETURN_CASE('d', double, numberWithDouble)
        JP_FFI_RETURN_CASE('B', BOOL, numberWithBool)
        case '^': {
            JPBoxing *box = [[JPBoxing alloc] init];
            box.pointer = (*(void**)src);
            return box;
        }
        case '@':
        case '#': {
            return (__bridge id)(*(void**)src);
        }
        case '{': {
            NSString *structName = [NSString stringWithCString:typeString encoding:NSASCIIStringEncoding];
            NSUInteger end = [structName rangeOfString:@"}"].location;
            if (end != NSNotFound) {
                structName = [structName substringWithRange:NSMakeRange(1, end - 1)];
                NSDictionary *structDefine = [JPExtension registeredStruct][structName];
                id dict = [JPExtension getDictOfStruct:src structDefine:structDefine];
                id ret = [JSValue valueWithObject:dict inContext:[JPEngine context]];
                return ret;
            }
        }
        default:
            return nil;
    }
}

+ (void)convertObject:(id)object toCValue:(void *)dist forType:(const char *)typeString
{
#define JP_CALL_ARG_CASE(_typeString, _type, _selector)\
    case _typeString:{\
        *(_type *)dist = [(NSNumber *)object _selector];\
        break;\
    }
    switch (typeString[0]) {
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
        JP_CALL_ARG_CASE('F', CGFloat, CGFloatValue)
        JP_CALL_ARG_CASE('d', double, doubleValue)
        JP_CALL_ARG_CASE('B', BOOL, boolValue)
        case '^': {
            void *ptr = [((JPBoxing *)object) unboxPointer];
            *(void **)dist = ptr;
            break;
        }
        case '#':
        case '@': {
            id ptr = object;
            *(void **)dist = (__bridge void *)(ptr);
            break;
        }
        case '{': {
            NSString *structName = [NSString stringWithCString:typeString encoding:NSASCIIStringEncoding];
            NSUInteger end = [structName rangeOfString:@"}"].location;
            if (end != NSNotFound) {
                structName = [structName substringWithRange:NSMakeRange(1, end - 1)];
                NSDictionary *structDefine = [JPExtension registeredStruct][structName];
                [JPExtension getStructDataWidthDict:dist dict:object structDefine:structDefine];
                break;
            }
        }
        default:
            break;
    }
}

+ (id)callCFunction:(NSString *)funcName arguments:(NSArray *)arguments
{
    void* functionPtr = dlsym(RTLD_DEFAULT, [funcName UTF8String]);
    if (!functionPtr) {
        return nil;
    }
    
    JPMethodSignature *funcSignature = [[JPMethodSignature alloc] initWithObjCTypes:[_funcDefines objectForKey:funcName]];
    
    NSUInteger argCount = funcSignature.argumentTypes.count;
    if (argCount != [arguments count]){
        return nil;
    }
    
    ffi_type **ffiArgTypes = alloca(sizeof(ffi_type *) *argCount);
    void **ffiArgs = alloca(sizeof(void *) *argCount);
    for (int i = 0; i < argCount; i ++) {
        const char *argumentType = [funcSignature.argumentTypes[i] UTF8String];
        ffi_type *ffiType = [JPMethodSignature ffiTypeWithEncodingChar:argumentType];
        ffiArgTypes[i] = ffiType;
        void *ffiArgPtr = alloca(ffiType->size);
        [self convertObject:arguments[i] toCValue:ffiArgPtr forType:argumentType];
        ffiArgs[i] = ffiArgPtr;
    }
    
    ffi_cif cif;
    id ret = nil;
    const char *returnTypeChar = [funcSignature.returnType UTF8String];
    ffi_type *returnFfiType = [JPMethodSignature ffiTypeWithEncodingChar:returnTypeChar];
    ffi_status ffiPrepStatus = ffi_prep_cif_var(&cif, FFI_DEFAULT_ABI, (unsigned int)0, (unsigned int)argCount, returnFfiType, ffiArgTypes);
    
    if (ffiPrepStatus == FFI_OK) {
        void *returnPtr = NULL;
        if (returnFfiType->size) {
            returnPtr = alloca(returnFfiType->size);
        }
        ffi_call(&cif, functionPtr, returnPtr, ffiArgs);

        if (returnFfiType->size) {
            ret = [self objectWithCValue:returnPtr forType:returnTypeChar];
        }
    }
    
    return ret;
}

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
