//
//  JPBlockWrapper.m
//  JSPatch
//
//  Created by bang on 1/19/17.
//  Copyright © 2017 bang. All rights reserved.
//

#import "JPBlockWrapper.h"
#import "ffi.h"
#import "JPEngine.h"
#import "JPMethodSignature.h"

enum {
    BLOCK_DEALLOCATING =      (0x0001),
    BLOCK_REFCOUNT_MASK =     (0xfffe),
    BLOCK_NEEDS_FREE =        (1 << 24),
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26),
    BLOCK_IS_GC =             (1 << 27),
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_USE_STRET =         (1 << 29),
    BLOCK_HAS_SIGNATURE  =    (1 << 30)
};

struct JPSimulateBlock {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct JPSimulateBlockDescriptor *descriptor;
};

struct JPSimulateBlockDescriptor {
    //Block_descriptor_1
    struct {
        unsigned long int reserved;
        unsigned long int size;
    };
    
    /*
    //Block_descriptor_2
    //no need
    struct {
        // requires BLOCK_HAS_COPY_DISPOSE
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
    };
    */
    
    //Block_descriptor_3
    struct {
        // requires BLOCK_HAS_SIGNATURE
        const char *signature;
        const char *layout;
    };
};



@interface JPBlockWrapper ()
{
    ffi_cif *_cifPtr;
    ffi_type **_args;
    ffi_closure *_closure;
    BOOL _generatedPtr;
    void *_blockPtr;
    struct JPSimulateBlockDescriptor *_descriptor;
}

@property (nonatomic,strong) JPMethodSignature *signature;
@property (nonatomic,strong) JSValue *jsFunction;

@end

void JPBlockInterpreter(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    JPBlockWrapper *blockObj = (__bridge JPBlockWrapper*)userdata;
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    for (int i = 1; i < blockObj.signature.argumentTypes.count; i ++) {
        id param;
        void *argumentPtr = args[i];
        const char *typeEncoding = [blockObj.signature.argumentTypes[i] UTF8String];
        switch (typeEncoding[0]) {
                
        #define JP_BLOCK_PARAM_CASE(_typeString, _type, _selector) \
            case _typeString: {                              \
                _type returnValue = *(_type *)argumentPtr;                     \
                param = [NSNumber _selector:returnValue];\
                break; \
            }
            JP_BLOCK_PARAM_CASE('c', char, numberWithChar)
            JP_BLOCK_PARAM_CASE('C', unsigned char, numberWithUnsignedChar)
            JP_BLOCK_PARAM_CASE('s', short, numberWithShort)
            JP_BLOCK_PARAM_CASE('S', unsigned short, numberWithUnsignedShort)
            JP_BLOCK_PARAM_CASE('i', int, numberWithInt)
            JP_BLOCK_PARAM_CASE('I', unsigned int, numberWithUnsignedInt)
            JP_BLOCK_PARAM_CASE('l', long, numberWithLong)
            JP_BLOCK_PARAM_CASE('L', unsigned long, numberWithUnsignedLong)
            JP_BLOCK_PARAM_CASE('q', long long, numberWithLongLong)
            JP_BLOCK_PARAM_CASE('Q', unsigned long long, numberWithUnsignedLongLong)
            JP_BLOCK_PARAM_CASE('f', float, numberWithFloat)
            JP_BLOCK_PARAM_CASE('d', double, numberWithDouble)
            JP_BLOCK_PARAM_CASE('B', BOOL, numberWithBool)
                
            case '@': {
                param = (__bridge id)(*(void**)argumentPtr);
                break;
            }
        }
        [params addObject:[JPExtension formatOCToJS:param]];
    }
    
    JSValue *jsResult = [blockObj.jsFunction callWithArguments:params];
    
    switch ([blockObj.signature.returnType UTF8String][0]) {
            
    #define JP_BLOCK_RET_CASE(_typeString, _type, _selector) \
        case _typeString: {                              \
            _type *retPtr = ret; \
            *retPtr = [((NSNumber *)[jsResult toObject]) _selector];   \
            break; \
        }
        
        JP_BLOCK_RET_CASE('c', char, charValue)
        JP_BLOCK_RET_CASE('C', unsigned char, unsignedCharValue)
        JP_BLOCK_RET_CASE('s', short, shortValue)
        JP_BLOCK_RET_CASE('S', unsigned short, unsignedShortValue)
        JP_BLOCK_RET_CASE('i', int, intValue)
        JP_BLOCK_RET_CASE('I', unsigned int, unsignedIntValue)
        JP_BLOCK_RET_CASE('l', long, longValue)
        JP_BLOCK_RET_CASE('L', unsigned long, unsignedLongValue)
        JP_BLOCK_RET_CASE('q', long long, longLongValue)
        JP_BLOCK_RET_CASE('Q', unsigned long long, unsignedLongLongValue)
        JP_BLOCK_RET_CASE('f', float, floatValue)
        JP_BLOCK_RET_CASE('d', double, doubleValue)
        JP_BLOCK_RET_CASE('B', BOOL, boolValue)
            
        case '@':
        case '#': {
            id retObj = [JPExtension formatJSToOC:jsResult];
            void **retPtrPtr = ret;
            *retPtrPtr = (__bridge void *)retObj;
            break;
        }
        case '^': {
            JPBoxing *box = [JPExtension formatJSToOC:jsResult];
            void *pointer = [box unboxPointer];
            void **retPtrPtr = ret;
            *retPtrPtr = pointer;
            break;
        }
    }
    
}

@implementation JPBlockWrapper

- (id)initWithTypeString:(NSString *)typeString callbackFunction:(JSValue *)jsFunction
{
    self = [super init];
    if(self) {
        _generatedPtr = NO;
        self.jsFunction = jsFunction;
        self.signature = [[JPMethodSignature alloc] initWithBlockTypeNames:typeString];
    }
    return self;
}

- (void *)blockPtr
{
    if (_generatedPtr) {
        return _blockPtr;
    }
    
    _generatedPtr = YES;
    
    ffi_type *returnType = [JPMethodSignature ffiTypeWithEncodingChar:[self.signature.returnType UTF8String]];
    
    NSUInteger argumentCount = self.signature.argumentTypes.count;
    
    _cifPtr = malloc(sizeof(ffi_cif));
    
    void *blockImp = NULL;
    
    _args = malloc(sizeof(ffi_type *) *argumentCount) ;
    
    for (int i = 0; i < argumentCount; i++){
        ffi_type* current_ffi_type = [JPMethodSignature ffiTypeWithEncodingChar:[self.signature.argumentTypes[i] UTF8String]];
        _args[i] = current_ffi_type;
    }
    
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&blockImp);
    
    if(ffi_prep_cif(_cifPtr, FFI_DEFAULT_ABI, (unsigned int)argumentCount, returnType, _args) == FFI_OK) {
        if (ffi_prep_closure_loc(_closure, _cifPtr, JPBlockInterpreter, (__bridge void *)self, blockImp) != FFI_OK) {
            NSAssert(NO, @"generate block error");
        }
    }
    
    struct JPSimulateBlockDescriptor descriptor = {
        0,
        sizeof(struct JPSimulateBlock),
        [self.signature.types cStringUsingEncoding:NSUTF8StringEncoding],
        NULL
    };
    
    _descriptor = malloc(sizeof(struct JPSimulateBlockDescriptor));
    memcpy(_descriptor, &descriptor, sizeof(struct JPSimulateBlockDescriptor));
    
    struct JPSimulateBlock simulateBlock = {
        &_NSConcreteStackBlock,
        (BLOCK_HAS_SIGNATURE), 0,
        blockImp,
        _descriptor
    };
    
    _blockPtr = malloc(sizeof(struct JPSimulateBlock));
    memcpy(_blockPtr, &simulateBlock, sizeof(struct JPSimulateBlock));
    
    return _blockPtr;
}

- (void)dealloc
{
    ffi_closure_free(_closure);
    free(_args);
    free(_cifPtr);
    free(_blockPtr);
    free(_descriptor);
    return;
}

@end
