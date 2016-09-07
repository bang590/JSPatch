include('protocolTest.js')
include('newProtocolTest.js')
var global = this;

require('JPEngine').defineStruct({
    "name": "UIEdgeInsets",
    "types": "FFFF",
    "keys": ["top", "left", "bottom", "right"]
});

(function() {
  defineClass("JPTestObject", {
    funcToSwizzle_view: function(num, view) {
      self.ORIGfuncToSwizzle_view(num, view) 
      self.setFuncToSwizzleViewPassed(view && 4.2 - num < 0.01)
    },
    funcToSwizzleWithString_view_int: function(str, view, i) {
      self.setFuncToSwizzleWithStringViewIntPassed(str.toJS() == "stringFromOC" && view && i == 42)
    },
    funcToSwizzleReturnView: function(view) {
      return view
    },
    funcToSwizzleReturnInt: function(num) {
      return num
    },
    funcToSwizzleReturnDictionary: function(dict) {
      return dict
    },
    funcToSwizzleReturnJSDictionary: function() {
      return {"str" : "js_string"};
    },
    funcToSwizzleReturnArray: function(arr) {
      return arr
    },
    funcToSwizzleReturnString: function(str) {
      return str
    },
    funcToSwizzleWithBlock: function(blk) {
      blk(UIView.alloc().init(), 42)
    },
    funcToSwizzle__withUnderLine__: function(num) {
      self.setFuncToSwizzle__withUnderLine__Passed(num == 42)
    },
    funcOverrideParentMethod:function(){
      return "overrided";
    },
    funcToSwizzleReturnRect: function(rect) {
      self.setFuncToSwizzleReturnRectJSPassed(rect.width == 100)
      return rect;
    },
    funcToSwizzleReturnSize: function(size) {
      self.setFuncToSwizzleReturnSizeJSPassed(size.width == 42)
      return size;
    },
    funcToSwizzleReturnPoint: function(point) {
      self.setFuncToSwizzleReturnPointJSPassed(point.x == 42)
      return point;
    },
    funcToSwizzleReturnRange: function(range) {
      self.setFuncToSwizzleReturnRangeJSPassed(range.length == 42)
      return range;
    },
    funcToSwizzleReturnEdgeInsets: function(edge) {
        self.setFuncToSwizzleReturnEdgeInsetsJSPassed(edge.top == 42)
        return edge;
    },
    funcToSwizzleTestGCD: function(completeBlock) {
      var execCount = 0
      var slf = self
      var dispatchExecBlock = function() {
        if (++execCount >= 4) {
          slf.setFuncToSwizzleTestGCDPassed(1)
          completeBlock()
        }
      }
      dispatch_async_main(dispatchExecBlock);
      dispatch_async_global_queue(dispatchExecBlock);
      dispatch_sync_main(dispatchExecBlock);
      dispatch_after(1, dispatchExecBlock);
    },
    funcToSwizzleTestClass: function(cls) {
      return cls
    },
    funcToSwizzleTestSelector: function(sel) {
      return sel
    },
    funcToSwizzleTestChar: function(cStr) {
      return cStr
    },
    funcToSwizzleTestPointer: function(pointer) {
      return pointer
    },
  },
  {
    classFuncToSwizzle_int: function(o, num) {
      o.setClassFuncToSwizzlePassed(num == 10)
    },
    classFuncToSwizzleReturnObj: function(o) {
      self.ORIGclassFuncToSwizzleReturnObj(o)
      return o
    },
    classFuncToSwizzleReturnInt: function(i) {
      return i
    },
    ///////Test for function which return double/float, cause there's a fatal bug in NSInvocation on iOS7.0
    classFuncToSwizzleReturnDouble: function(d) {
      return d
    }
  })
  defineClass("JPTestSwizzledForwardInvocationSubObject",{
    stubMethod: function() {}
  })

  var JPTestObject = require("JPTestObject") 
  var UIView = require("UIView") 
  var obj = JPTestObject.alloc().init() 
  global.ocObj = obj.__obj;

  ////////Swizzle
  obj.callSwizzleMethod()

  var cls = obj.funcToSwizzleTestClass(JPTestObject.class())
  obj.setFuncToSwizzleTestClassPassed(obj.isKindOfClass(cls))

  obj.funcTestChar(obj.funcReturnChar())
  var pointer = obj.funcReturnPointer()

  ////////Base
  obj.funcReturnVoid();
  var testReturnString = obj.funcReturnString().toJS();
  obj.setFuncReturnStringPassed(testReturnString == "stringFromOC")

  ///////Test for functions which return double/float, cause there's a fatal bug in NSInvocation on iOS7.0
  var testReturnDouble = obj.funcReturnDouble()
  console.log(testReturnDouble == 100)
  obj.setFuncReturnDoublePassed(testReturnDouble == 100)

  obj.funcWithInt(42);
  obj.funcWithDict_andDouble({test: "test"}, 4.2)
 
  //////nil / NSNull
  obj.funcWithNil_dict_str_num(null, {k: "JSPatch"}, "JSPatch", 4.2)
  obj.funcWithNull(nsnull)
  var o = obj.funcReturnNil()
  obj.funcWithNil(o)
  obj.setFuncReturnNilPassed(!o)
  o.callAnyMethod().willNotCrash()
  
  var bTrue = obj.funcTestBool(true)
  var bFalse = obj.funcTestBool(false)
  var bFalseNum = obj.funcTestBool(0)
  obj.setFuncTestBoolPassed(bTrue && !bFalse && !bFalseNum)
 
  var num0 = obj.funcTestNSNumber(0)
  var num1 = obj.funcTestNSNumber(1)
  obj.setFuncTestNSNumberPassed(num0 === 0 && num1 === 1)

  ///////UIView/NSObject
  var view = obj.funcReturnViewWithFrame({
    x: 0,
    y: 0,
    width: 100,
    height: 100
  });
  var viewFrame = view.frame() 
  obj.setFuncReturnViewWithFramePassed(viewFrame.width == 100 && viewFrame.height == 100)

  var newView = UIView.alloc().initWithFrame({
    x: 10,
    y: 10,
    width: 20,
    height: 20
  })
  var returnedView = obj.funcWithViewAndReturnView(newView);
  var returnedViewFrame = returnedView.frame() 
  obj.setFuncWithViewAndReturnViewPassed(returnedViewFrame.width == 20 && returnedViewFrame.x == 10)

  //////CGRect/CGPoint/CGSize/NSRange
  var rect = obj.funcWithRectAndReturnRect({
    x: 10,
    y: 10,
    width: 4.2,
    height: 4.2
  });
  obj.setFuncWithRectAndReturnRectPassed(rect.x == 10 && rect.y == 10 && rect.width - 4.2 < 0.01 && rect.height - 4.2 < 0.01)

  var point = obj.funcWithPointAndReturnPoint({
    x: 10,
    y: 10
  });
  obj.setFuncWithPointAndReturnPointPassed(point.x == 10 && point.y == 10)

  var size = obj.funcWithSizeAndReturnSize({
    width: 10,
    height: 10
  });
  obj.setFuncWithSizeAndReturnSizePassed(size.width == 10 && size.height == 10)

  var range = obj.funcWithRangeAndReturnRange({
    location: 0,
    length: 100
  });
  obj.setFuncWithRangeAndReturnRangePassed(range.location == 0 && range.length == 100)

  /////Dictionary/Array
  var dict = obj.funcReturnDictStringInt().toJS()
  obj.setFuncReturnDictStringIntPassed(dict["str"] == "stringFromOC" && dict["num"] == 42)

  var dict = obj.funcReturnDictStringView().toJS();
  var dictViewFrame = dict["view"].frame() 
  obj.setFuncReturnDictStringViewPassed(dict.str == "stringFromOC" && dictViewFrame.width == 100)

  var arr = obj.funcReturnArrayControllerViewString().toJS()
  obj.setFuncReturnArrayControllerViewStringPassed(arr[0] && arr[1] && arr[2] == "stringFromOC")

  var dict = obj.funcReturnDict({name: "JSPatch"}).toJS()
  obj.setFuncReturnDictPassed(dict.name == "JSPatch")
 
  //////property
  var view = UIView.alloc().init();
  view.setFrame({
    x: 10,
    y: 10,
    width: 100,
    height: 100
  }) 
  obj.setPropertySetFramePassed(view.frame().width == 100 && view.bounds().height == 100)

  obj.testView = view 
  obj.setPropertySetViewPassed(obj.testView.frame().x == 10)

  /////Block
  var blk = obj.funcReturnBlock();
  blk("stringFromJS", 42);

  var blk = obj.funcReturnObjectBlock();
  var view = UIView.alloc().initWithFrame({
    x: 10,
    y: 10,
    width: 100,
    height: 100
  }) 
  var blkRet = blk({
    str: "stringFromJS",
    view: view
  }, view)
  obj.setFuncReturnObjectBlockReturnValuePassed(blkRet.toJS() == "succ")

  obj.callBlockWithStringAndInt(block("NSString *, int", function(str, num) {
    obj.setCallBlockWithStringAndIntPassed(str.toJS() == "stringFromOC" && num == 42)
    return "succ"
  }))

  obj.callBlockWithArrayAndView(block("NSArray *, UIView *", function(arr, view) {
    var viewFrame = view.frame()
    arr = arr.toJS()
    obj.setCallBlockWithArrayAndViewPassed(arr[0] == "stringFromOC" && arr[1] && viewFrame.width == 100)
  }))

  obj.callBlockWithBoolAndBlock(block("BOOL, NSBlock *", function(b, blk) {
    blk("stringFromJS", b ? 42 : 0);
  }))

  obj.callBlockWithObjectAndBlock(block("UIView *, NSBlock *", function(view, blk) {
    var viewFrame = view.frame()
    var ret = blk((viewFrame.width == 100 ? {
      "str": "stringFromJS",
      "view": view
    }: {}), view)
    obj.setCallBlockWithObjectAndBlockReturnValuePassed(ret.toJS() == "succ")
  }))
    
  //////super
  var subObj = require("JPTestSubObject").alloc().init() 
  global.subObj = subObj.__obj;
  subObj.super().funcCallSuper()

  //////forwardInvocation
  obj.callTestForward()

  //////new class
  var JPNewTestObject = defineClass("JPNewTestObject", {
    funcReturnView: function(x) {
      var view = UIView.alloc().initWithFrame({
        x: x,
        y: 10,
        width: 20,
        height: 20
      }) 
      return view
    }
  },
  {
    funcReturnBool: function(view, num) {
      return view && num == 42
    }
  })

  var newTestObj = JPNewTestObject.alloc().init()

  var view = newTestObj.funcReturnView(42) 
  obj.setNewTestObjectReturnViewPassed(view.frame().x == 42) 
  obj.setNewTestObjectReturnBoolPassed(JPNewTestObject.funcReturnBool(view, 42))
 
  //mutable
  var arr = require('NSMutableArray').alloc().init()
  arr.addObject("ctn")
  obj.setMutableArrayPassed(arr.objectAtIndex(0).toJS() == "ctn")

  var dict = require('NSMutableDictionary').alloc().init()
  dict.setObject_forKey("ctn", "k")
  obj.setMutableDictionaryPassed(dict.objectForKey("k").toJS() == "ctn")

  var str = require('NSMutableString').alloc().init()
  str.appendString("JS")
  str.appendString("Patch")
  obj.setMutableStringPassed(str.toJS() == "JSPatch")
 
  var arr = []
  arr.push(obj.getString(), obj.getDictionary(), obj.getArray())
  obj.funcTestBoxingObj(arr)

  obj.setConsoleLogPassed(console.log != undefined)



  //extension
  var transform = obj.funcWithTransform({tx: 100, ty: 100, a: 1, b: 0, c: 0, d: 1})
  obj.setFuncWithTransformPassed(transform.tx == 100 && transform.ty == 100 && transform.a == 1)
  var translated = CGAffineTransformTranslate(transform, 10, 10);
  obj.setTransformTranslatePassed(translated.tx == 110 && translated.ty == 110)
 
  obj.funcTestPointer(pointer)
  free(pointer)
 
  //sizeof
  var rectSize       = sizeof("CGRect")
  var pointSize      = sizeof("CGPoint")
  var sizeSize       = sizeof("CGSize")
  var vectorSize     = sizeof("CGVector")
  var edgeInsetsSize = sizeof("UIEdgeInsets")
  var transformSize  = sizeof("CGAffineTransform")
  var rangeSize      = sizeof("NSRange")
  obj.setFuncTestSizeofPassed(rectSize > 0 && pointSize > 0 && sizeSize > 0 && vectorSize > 0 && edgeInsetsSize > 0 && transformSize > 0 && rangeSize > 0)
 
//getPointerTest1 - Test Object in JPBoxing
  var sig = require('JPTestObject').instanceMethodSignatureForSelector("funcTestGetPointer1:");
  var invocation = require('NSInvocation').invocationWithMethodSignature(sig)
  var str = require('NSString').stringWithString('JSPatch')
  invocation.setTarget(obj)
  invocation.setSelector("funcTestGetPointer1:")
  invocation.setArgument_atIndex(getPointer(str), 2)
  invocation.invoke()
  var ret1 = malloc(1)
  invocation.getReturnValue(ret1)
  var bool1 =  pvalBool(ret1)
 
//getPointerTest2 -  Test Normal Object
  var sig = require('JPTestObject').instanceMethodSignatureForSelector("funcTestGetPointer2:");
  var invocation = require('NSInvocation').invocationWithMethodSignature(sig)
  var err = require('NSError').errorWithDomain_code_userInfo("com.albert43",45,{msg:"test"});
  invocation.setTarget(obj)
  invocation.setSelector("funcTestGetPointer2:")
  invocation.setArgument_atIndex(getPointer(err), 2)
  invocation.invoke()
  var ret2 = malloc(1)
  invocation.getReturnValue(ret2);
  var bool2 =  pvalBool(ret2)

//getPointerTest3 -  Test Pointer
  var ptr = malloc(10)
  memset(ptr, 65, 10)
  var sig = require('JPTestObject').instanceMethodSignatureForSelector("funcTestGetPointer3:");
  var invocation = require('NSInvocation').invocationWithMethodSignature(sig)
  invocation.setTarget(obj)
  invocation.setSelector("funcTestGetPointer3:")
  invocation.setArgument_atIndex(getPointer(ptr), 2)
  invocation.invoke()
  var ret3 = malloc(1)
  invocation.getReturnValue(ret3);
  var bool3 =  pvalBool(ret3)
  obj.setFuncTestGetPointerPassed(bool1 && bool2 && bool3)
  free(ret1)
  free(ret2)
  free(ret3)
  free(ptr)
 
//funcTestNSErrorPointer
  var p_error = malloc(8)
  obj.funcTestNSErrorPointer(p_error)
  var error = pval(p_error)
  if (!error) {
     obj.setFuncTestNSErrorPointerPassed(false)
  } else {
    var code = error.code()
    obj.setFuncTestNSErrorPointerPassed(code==43)
  }
  releaseTmpObj(p_error)
  free(p_error)

//funcTestNilParametersInBlock
  var blk  = obj.funcGenerateBlock()
  var str1 = blk(obj.funcReturnNil())
  var str2 = blk(null)
  var str3 = obj.excuteBlockWithNilParameters(block("NSError *", blk))
  if (str1.toJS() == "no error" && str2.toJS() == "no error" && str3.toJS() == "no error") {
    obj.setFuncTestNilParametersInBlockPassed(true)
  }

//newStruct
  var pRect = newStruct('CGRect', {x:0, y:0, width:100, height:100});
  obj.funcWithRectPointer(pRect);
  var rect = pvalStruct('CGRect', pRect);
  obj.setFuncWithRectPointerPassed(obj.funcWithRectPointerPassed() && rect.x == 42)
  free(pRect);
 
  var pTransform = newStruct('CGAffineTransform', {tx:0, ty:0, a:100, b:100, c:0, d:0});
  obj.funcWithTransformPointer(pTransform);
  var transform = pvalStruct('CGAffineTransform', pTransform);
  obj.setFuncWithTransformPointerPassed(obj.funcWithTransformPointerPassed() && transform.tx == 42)
  free(pTransform);

    
//variable parameter method
  var strWithFormat = require('NSString').stringWithFormat("%@ %@", "a", "b");
  obj.setVariableParameterMethodPassed(strWithFormat.toJS() == "a b");
   
})();