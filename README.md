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

#### 1. require 

Call `require('className')` before using the Objective-C class. You can use `,` to separate multiple class to import them at one time. 

```js
require('UIView, UIColor')
var view = UIView.alloc().init()
var red = UIColor.redColor()
var ctrl = require('UIViewController').alloc().init()
```

####2. Invoking method
```js
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

```

####3. defineClass
You can define a new Objective-C class in JavaScript:

```js
defineClass("JPViewController: UIViewController", {
  //instance method definitions
  viewDidLoad: function() {
    //use self.super to call super method
    self.super.viewDidLoad()

    //do something here
  },

  viewDidAppear: function(animated) {

  }
}, {
  //class method definitions
  description: function() {
    return "I'm JPViewController"
  } 
})
```

Or you can redefine an exists class and override methods.

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
    if (self.dataSource().length > row) {  //fix the out of bound bug here
      var content = self.dataSource()[row];
      var ctrl = JPViewController.alloc().initWithContent(content);
      self.navigationController().pushViewController(ctrl);
    }
  },

  dataSource: function() {
    // get the original method by adding prefix 'ORIG'
    var data = self.ORIGdataSource();
    return data.push('Good!');
  }
}, {})
```

#### 4. CGRect / CGPoint / CGSize / NSRange
Use hashes:

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
You should indicate each type of params when passing block from js to objc.
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
  if (succ) log(ctn)  //output: I'm content
}));
```

Just call directly when the block passing from objc to js:

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

####6. dispatch
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


## Enviroment
- iOS 7+
- JavaScriptCore.framework
- Support armv7/armv7s/arm64
