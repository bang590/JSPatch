# JSPatch
[![Travis](https://img.shields.io/travis/bang590/JSPatch.svg)](https://github.com/bang590/JSPatch)
[![License](https://img.shields.io/github/license/bang590/JSPatch.svg?style=flat)](https://github.com/bang590/JSPatch/blob/master/LICENSE)

JSPatch 可以让你用 JavaScript 书写原生 iOS APP。只需在项目引入极小的引擎，就可以使用 JavaScript 调用任何 Objective-C 的原生接口，获得脚本语言的优势：为项目动态添加模块，或替换项目原生代码动态修复 bug。

项目仍在开发中，欢迎一起完善这个项目。

## 示例

```objc
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    [JPEngine startEngine];
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window addSubview:[self genView]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UIView *)genView
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
}

@end
```

```js
// demo.js
require('UIView, UIColor, UILabel')
defineClass('AppDelegate', {
  // replace the -genView method
  genView: function() {
    var view = self.ORIGgenView();
    view.setBackgroundColor(UIColor.greenColor())
    var label = UILabel.alloc().initWithFrame(view.frame());
    label.setText("JSPatch");
    label.setTextAlignment(1);
    view.addSubview(label);
    return view;
  }
});
```


## 安装

拷贝 `JSPatch/` 目录下的三个文件 `JSEngine.m` / `JSEngine.h` / `JSPatch.js` 到项目里即可。

## 使用

### Objective-C:
1. `#import "JPEngine.h"`
2. 调用`[JPEngine startEngine]`
3. 通过`[JPEngine evaluateScript:@""]`接口执行 JavaScript。

```objc
[JPEngine startEngine];

// 直接执行js
[JPEngine evaluateScript:@"\
 var alertView = require('UIAlertView').alloc().init();\
 alertView.setTitle('Alert');\
 alertView.setMessage('AlertView from js'); \
 alertView.addButtonWithTitle('OK');\
 alertView.show(); \
"];

// 从网络拉回js脚本执行
[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cnbang.net/test.js"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [JPEngine evaluateScript:script];
}];

// 执行本地js文件
NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"js"];
NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
[JPEngine evaluateScript:script];
```

### JavaScript:

#### 1. require 

使用某个 Objective-C 类前，先调用 require('className')，然后可以直接使用这个类。可以用逗号分隔一次性引入多个类。

```js
require('UIView, UIColor')
var view = UIView.alloc().init()
var red = UIColor.redColor()
var ctrl = require('UIViewController').alloc().init()
```

#### 2. 方法调用
```js
require('UIView, UIColor, UISlider, NSIndexPath')

// 调用类方法
var redColor = UIColor.redColor();

// 调用实例方法
var view = UIView.alloc().init();
view.setNeedsLayout();

// setProerty
view.setBackgroundColor(redColor);

// getProperty 
var bgColor = view.backgroundColor();

// 多参数方法名用'_'隔开：
// OC：NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1]
var indexPath = NSIndexPath.indexPathForRow_inSection(0, 1);

```

#### 3. defineClass
可以新定义一个 Objective-C class，重写父类里的方法。

```js
defineClass("JPViewController: UIViewController", {
  // instance method definitions
  viewDidLoad: function() {
    //use self.super to call super method
    self.super.viewDidLoad()

    // do something here
  },

  viewDidAppear: function(animated) {

  }
}, {
  // class method definitions
  description: function() {
    return "I'm JPViewController"
  } 
})
```

可以定义 Objective-C 里已存在的类，对类和实例方法进行动态替换。

```objc
// OC
@implementation JPTableViewController
...
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *content = self.dataSource[[indexPath row]];  // may cause out of bound
  JPViewController *ctrl = [[JPViewController alloc] initWithContent:content];
  [self.navigationController pushViewController:ctrl];
}
- (NSArray *)dataSource
{
  return @[@"JSPatch", @"is"];
}
- (void)customMethod
{
  NSLog(@"callCustom method")
}
@end
```

```objc
// JS
defineClass("JPTableViewController", {
  // instance method definitions
  tableView_didSelectRowAtIndexPath: function(tableView, indexPath) {
    var row = indexPath.row()
    if (self.dataSource().length > row) {  //fix the out of bound bug here
      var content = self.dataSource()[row];
      var ctrl = JPViewController.alloc().initWithContent(content);
      self.navigationController().pushViewController(ctrl);
    }
  },

  dataSource: function() {
    // 函数名前加'ORIG'可以调回OC定义的原方法
    var data = self.ORIGdataSource();
    return data.push('Good!');
  }
}, {})
```
执行以上 JavaScript 脚本后，JPTableViewController 的方法就被替换成 JavaScript 里的实现。


#### 4. CGRect / CGPoint / CGSize / NSRange
针对这几个常用的 struct 会转为字典表示：

```objc
// OC
UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
CGFloat x = view.frame.origin.x;
```

```js
// JS
var view = UIView.alloc().initWithFrame({x:20, y:20, width:100, height:100});
var x = view.bounds.x;
```

#### 5. block
block 从 JavaScript 传入 Objective-C 时，需要写上每个参数的类型。

```objc
// OC
@implementation JPObject
+ (void)request:(void(^)(NSString *content, BOOL success))callback
{
  callback(@"I'm content", YES);
}
@end
```

```js
// JS
require('JPObject').request(block("NSString *, BOOL", function(ctn, succ) {
  if (succ) log(ctn)  // output: I'm content
}));
```

block 从 Objective-C 传给 JavaScript 时，可以直接调用。

```objc
// OC
@implementation JPObject
typedef void (^JSBlock)(NSDictionary *dict);
+ (JSBlock)genBlock
{
  NSString *ctn = @"JSPatch";
  JSBlock block = ^(NSDictionary *dict) {
    NSLog(@"I'm %@, version: %@", ctn, dict[@"v"])
  };
  return block;
}
@end
```

```js
// JS
var blk = require('JPObject').genBlock();
blk({v: "0.0.1"});  //output: I'm JSPatch, version: 0.0.1
```

#### 6. dispatch
Using `dispatch_after()` `dispatch_async_main()` `dispatch_sync_main()` `dispatch_async_global_queue()` to call GCD.

```objc
// OC
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
  // do something
});

dispatch_async(dispatch_get_main_queue(), ^{
  // do something
});
```

```js
// JS
dispatch_after(function(1.0, function(){
  // do something
}))
dispatch_async_main(function(){
  // do something
})
```

## 运行环境
- iOS 7+
- JavaScriptCore.framework
- 支持 armv7/armv7s/arm64
