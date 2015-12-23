# JSPatch

JSPatch 可以让你用 JavaScript 书写原生 iOS APP。只需在项目引入极小的引擎，就可以使用 JavaScript 调用任何 Objective-C 的原生接口，获得脚本语言的优势：为项目动态添加模块，或替换项目原生代码动态修复 bug。

项目仍在开发中，欢迎一起完善这个项目。

**注意**：完善的文档请移步 [Wiki](https://github.com/bang590/JSPatch/wiki/)。

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

可以使用 [JSPatch Convertor](https://github.com/bang590/JSPatchConvertor) 自动把 Objective-C 代码转为 JavaScript 代码。

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

#### 基础使用方式

```js
// 调用require引入要使用的OC类
require('UIView, UIColor, UISlider, NSIndexPath')

// 调用类方法
var redColor = UIColor.redColor();

// 调用实例方法
var view = UIView.alloc().init();
view.setNeedsLayout();

// set proerty
view.setBackgroundColor(redColor);

// get property 
var bgColor = view.backgroundColor();

// 多参数方法名用'_'隔开：
// OC：NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
var indexPath = NSIndexPath.indexPathForRow_inSection(0, 1);

// 方法名包含下划线'_'，js用双下划线表示
// OC: [JPObject _privateMethod];
JPObject.__privateMethod()

// 如果要把 `NSArray` / `NSString` / `NSDictionary` 转为对应的 JS 类型，使用 `.toJS()` 接口.
var arr = require('NSMutableArray').alloc().init()
arr.addObject("JS")
jsArr = arr.toJS()
console.log(jsArr.push("Patch").join(''))  //output: JSPatch

// 在JS用字典的方式表示 CGRect / CGSize / CGPoint / NSRange
var view = UIView.alloc().initWithFrame({x:20, y:20, width:100, height:100});
var x = view.bounds().x;

// block 从 JavaScript 传入 Objective-C 时，需要写上每个参数的类型。
// OC Method: + (void)request:(void(^)(NSString *content, BOOL success))callback
require('JPObject').request(block("NSString *, BOOL", function(ctn, succ) {
  if (succ) log(ctn)
}));

// GCD
dispatch_after(function(1.0, function(){
  // do something
}))
dispatch_async_main(function(){
  // do something
})
```

详细文档请参考wiki页面：[Base Usage](https://github.com/bang590/JSPatch/wiki/Base-usage)


#### 定义类/替换方法

用 `defineClass()` 定义 Objective-C 的类，对类和实例方法进行动态替换。

```objc
// OC
@implementation JPTableViewController
...
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *content = self.dataSource[[indexPath row]];  //may cause out of bound
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
    if (self.dataSource().count() > row) {  //fix the out of bound bug here
      var content = self.dataSource().objectAtIndex(row);
      var ctrl = JPViewController.alloc().initWithContent(content);
      self.navigationController().pushViewController(ctrl);
    }
  },

  dataSource: function() {
    // get the original method by adding prefix 'ORIG'
    var data = self.ORIGdataSource().toJS();
    return data.push('Good!');
  }
}, {})
```

详细文档请参考wiki页面：[Usage of defineClass](https://github.com/bang590/JSPatch/wiki/Usage-of-defineClass)


#### 扩展

一些自定义的struct类型、C函数调用以及其他功能可以通过扩展实现，调用 `+addExtensions:` 可以加载扩展接口：

```objc
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    [JPEngine startEngine];

    //添加扩展
    [JPEngine addExtensions:@[@"JPInclude", @"JPCGTransform"]];

    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];
}
```

```js
include('test.js')   //`include()`方法在扩展 JPInclude.m 里提供
var view = require('UIView').alloc().init()

//struct CGAffineTransform 类型在 JPCGTransform.m 里提供支持
view.setTransform({a:1, b:0, c:0, d:1, tx:0, ty:100})
```

扩展可以在JS动态加载，更推荐这种加载方式，在需要用到时才加载：

```js
require('JPEngine').addExtensions(['JPInclude', 'JPCGTransform'])

// `include()` and `CGAffineTransform` is avaliable now.
```

可以通过新增扩展为自己项目里的 struct 类型以及C函数添加支持，详情请见wiki页面：[Adding new extensions](https://github.com/bang590/JSPatch/wiki/Adding-new-extensions)


## 运行环境
- iOS 7+
- JavaScriptCore.framework
- 支持 armv7/armv7s/arm64
