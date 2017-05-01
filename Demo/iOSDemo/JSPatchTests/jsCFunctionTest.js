require('JPEngine').addExtensions(['JPCFunction'])
require('JPEngine').defineStruct({
    "name": "CGSize",
    "types": "FF",
    "keys": ["width", "height"]
});
require('JPEngine').defineStruct({
    "name": "CGPoint",
    "types": "FF",
    "keys": ["x", "y"]
});
require('JPEngine').defineStruct({
    "name": "CGRect",
    "types": "{CGPoint}{CGSize}",
    "keys": ["origin", "size"]
});

defineClass('JPCFunctionTest', {}, {
    testCfuncWithCGSize: function() {
        defineCFunction("cfuncWithCGSize", "{CGSize}, {CGSize}")
        var ret = cfuncWithCGSize({width:1, height:2});
        return ret.width == 1 && ret.height == 2;
    },
    testCfuncWithCGRect: function() {
        defineCFunction("cfuncWithCGRect", "{CGRect}, {CGRect}")
        var ret = cfuncWithCGRect({origin:{x:1,y:2},size:{width:3, height:4}});
        console.log("testCfuncWithCGRect", JSON.stringify(ret), ret.origin, ret.origin.x);
        return ret.origin.x == 1 && ret.origin.y == 2 && ret.size.width == 3 && ret.size.height == 4;
    },
    testCfuncWithId: function() {
        defineCFunction("cfuncWithId", "id, NSString *")
        var ret = cfuncWithId("JSPatch");
        return ret.toJS() == "JSPatch";
    },
    testCfuncWithInt: function() {
        defineCFunction("cfuncWithInt", "int, int")
        return cfuncWithInt(42) == 42
    },
    testCfuncWithCGFloat: function() {
        defineCFunction("cfuncWithCGFloat", "CGFloat, CGFloat")
        return cfuncWithCGFloat(42.2) - 42.2 < 0.1
    },
    testCfuncReturnPointer: function() {
        defineCFunction("cfuncReturnPointer", "void*")
        defineCFunction("cfuncWithPointerIsEqual", "bool, void*")
        var ptr = cfuncReturnPointer()
        return cfuncWithPointerIsEqual(ptr)
    },
    testCFunctionReturnClass: function() {
        defineCFunction("NSClassFromString", "Class, NSString *")
        var viewCls = NSClassFromString("UIView")
        var view = require('UIView').alloc().init()
        return view.isKindOfClass(viewCls);
    },
    testCFunctionVoid: function() {
        defineCFunction("cfuncVoid", "void")
        self.setupCFunctionVoidSucc();
        return self.ORIGtestCFunctionVoid();
    },
})
