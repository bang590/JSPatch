var global = this;

(function() {

  defineClass("JPTestObject", {
    funcToSwizzle_view: function(num, view) {
      self.ORIGfuncToSwizzle_view(num, view) 
      self.setFuncToSwizzleViewPassed(view && 4.2 - num < 0.01)
    },
    funcToSwizzleWithString_view_int: function(str, view, i) {
      self.setFuncToSwizzleWithStringViewIntPassed(str == "stringFromOC" && view && i == 42)
    },
    funcToSwizzleReturnView: function(view) {
      return view
    },
    funcToSwizzleReturnInt: function(num) {
      return num
    },
    funcCustom: function(num) {
      self.setCallCustomFuncPassed(num == 10)
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
      return rect;
    },
    funcToSwizzleReturnSize: function(size) {
      return size;
    },
    funcToSwizzleReturnPoint: function(point) {
      return point;
    },
    funcToSwizzleReturnRange: function(range) {
      return range;
    }
    
  },
  {
    classFuncToSwizzle_int: function(o, num) {
      o.setClassFuncToSwizzlePassed(num == 10)
    },
    classFuncToSwizzleReturnObj: function(o) {
      JPTestObject.ORIGclassFuncToSwizzleReturnObj(o) 
      return o
    },
    classFuncToSwizzleReturnInt: function(i) {
      return i
    }
  })

  var JPTestObject = require("JPTestObject") 
  var UIView = require("UIView") 
  var obj = JPTestObject.alloc().init() 
  global.ocObj = obj.__obj;

  ////////Swizzle
  obj.callSwizzleMethod() 
  obj.funcCustom(10)

  ////////Base
  obj.funcReturnVoid();
  var testReturnString = obj.funcReturnString();
  obj.setFuncReturnStringPassed(testReturnString == "stringFromOC")

  obj.funcWithInt(42);
  obj.funcWithDict_andDouble({test: "test"}, 4.2)

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
  var dict = obj.funcReturnDictStringInt();
  obj.setFuncReturnDictStringIntPassed(dict["str"] == "stringFromOC" && dict["num"] == 42)

  var dict = obj.funcReturnDictStringView();
  var dictViewFrame = dict["view"].frame() 
  obj.setFuncReturnDictStringViewPassed(dict.str == "stringFromOC" && dictViewFrame.width == 100)

  var arr = obj.funcReturnArrayControllerViewString()
  obj.setFuncReturnArrayControllerViewStringPassed(arr[0] && arr[1] && arr[2] == "stringFromOC")

  var dict = obj.funcReturnDict({name: "JSPatch"})
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
  blk({
    str: "stringFromJS",
    view: view
  }, view)

  obj.callBlockWithStringAndInt(block("NSString *, int", function(str, num) {
    obj.setCallBlockWithStringAndIntPassed(str == "stringFromOC" && num == 42)
  }))

  obj.callBlockWithArrayAndView(block("NSArray *, UIView *", function(arr, view) {
    var viewFrame = view.frame()
    obj.setCallBlockWithArrayAndViewPassed(arr[0] == "stringFromOC" && arr[1] && viewFrame.width == 100)
  }))

  obj.callBlockWithBoolAndBlock(block("BOOL, NSBlock *", function(b, blk) {
    blk("stringFromJS", b ? 42 : 0);
  }))

  obj.callBlockWithObjectAndBlock(block("UIView *, NSBlock *", function(view, blk) {
    var viewFrame = view.frame() 
    blk((viewFrame.width == 100 ? {
      "str": "stringFromJS",
      "view": view
    }: {}), view)
  }))

  //////super
  var subObj = require("JPTestSubObject").alloc().init() 
  global.subObj = subObj.__obj;
  subObj.super.funcCallSuper()

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
  },
  {
    customFunc: function(num) {
      var view = self.funcReturnView(num)
      obj.setNewTestObjectCustomFuncPassed(view.frame().x == num)
    }
  })

  var newTestObj = JPNewTestObject.alloc().init()

  var view = newTestObj.funcReturnView(42) 
  obj.setNewTestObjectReturnViewPassed(view.frame().x == 42) 
  obj.setNewTestObjectReturnBoolPassed(JPNewTestObject.funcReturnBool(view, 42))
  newTestObj.customFunc(42)
 
  obj.setConsoleLogPassed(console.log != undefined)

})();