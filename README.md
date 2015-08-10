# JSPatch
[![Travis](https://img.shields.io/travis/bang590/JSPatch.svg)](https://github.com/bang590/JSPatch)
![CocoaPods Version](https://img.shields.io/cocoapods/v/JSPatch.svg?style=flat)
[![License](https://img.shields.io/github/license/bang590/JSPatch.svg?style=flat)](https://github.com/bang590/JSPatch/blob/master/LICENSE)

JSPatch bridges Objective-C and JavaScript using the Objective-C runtime. You can call any Objective-C class and method in JavaScript by just including a small engine. That makes the APP obtaining the power of script language: add modules or replacing Objective-C code to fix bugs dynamically.

JSPatch is still in development, welcome to improve the project together.

## Example

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


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like JSPatch in your projects. See the ["Getting Started"](https://guides.cocoapods.org/using/getting-started.html) guide for more information.

```ruby
# Your Podfile
platform :ios, '7.0'
pod 'JSPatch'
```

### Manually

Copy `JSEngine.m` `JSEngine.h` `JSPatch.js` in `JSPatch/` to your project.


## Usage

### Objective-C
1. `#import "JPEngine.h"`
2. call `[JPEngine startEngine]`
3. exec JavasScript by `[JPEngine evaluateScript:@""]`

```objc
[JPEngine startEngine];

// exec js directly
[JPEngine evaluateScript:@"\
 var alertView = require('UIAlertView').alloc().init();\
 alertView.setTitle('Alert');\
 alertView.setMessage('AlertView from js'); \
 alertView.addButtonWithTitle('OK');\
 alertView.show(); \
"];

// exec js file from network
[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cnbang.net/test.js"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [JPEngine evaluateScript:script];
}];

// exec local js file
NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"js"];
NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
[JPEngine evaluateScript:script];
```

### JavaScript

#### Base Usage

```js
//require
require('UIView, UIColor, UISlider, NSIndexPath')

// Invoke class method
var redColor = UIColor.redColor();

// Invoke instance method
var view = UIView.alloc().init();
view.setNeedsLayout();

// set proerty
view.setBackgroundColor(redColor);

// get property 
var bgColor = view.backgroundColor();

// multi-params method (use underline to separate)
// OC：NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
var indexPath = NSIndexPath.indexPathForRow_inSection(0, 1);

// method name contains underline (use double undeline to represent)
// OC: [JPObject _privateMethod];
JPObject.__privateMethod()

// use .toJS() to convert NSArray / NSString / NSDictionary to JS type.
var arr = require('NSMutableArray').alloc().init()
arr.addObject("JS")
jsArr = arr.toJS()
console.log(jsArr.push("Patch").join(''))  //output: JSPatch

// use hashes to represent struct like CGRect / CGSize / CGPoint / NSRange
var view = UIView.alloc().initWithFrame({x:20, y:20, width:100, height:100});
var x = view.bounds.x;

// wrap function with `block()` when passing block from JS to OC
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

Go to wiki page for more details: [Base Usage](https://github.com/bang590/JSPatch/wiki/Base-usage)



####defineClass
You can redefine an existing class and override methods.

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

Go to wiki page for more details: [Usage of defineClass](https://github.com/bang590/JSPatch/wiki/Usage-of-defineClass)

####Extensions

There are some extensions provide support for custom struct type, C methods and other functional, call `+addExtensions:` after starting engine to add extensions:

```objc
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    [JPEngine startEngine];

    //add extensions after startEngine
    [JPEngine addExtensions:@[[JPInclude instance], [JPCGTransform instance]]];

    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];
}

@end
```

```js
include('test.js')   //include function provide by JPInclude.m
var view = require('UIView').alloc().init()

//CGAffineTransform is supported in JPCGTransform.m
view.setTransform({a:1, b:0, c:0, d:1, tx:0, ty:100})
```

Extensions can be added dynamiclly in JS, which is recommended:

```js
require('JPEngine').addExtensions([
  require('JPInclude').instance(), 
  require('JPCGTransform').instance(),
])

// `include()` and `CGAffineTransform` is avaliable now.
```

You can create your own extension to support custom struct type and C methods in project, see the wiki page for more details: [Adding new extensions](https://github.com/bang590/JSPatch/wiki/Adding-new-extensions)


## Enviroment
- iOS 7+
- JavaScriptCore.framework
- Support armv7/armv7s/arm64
