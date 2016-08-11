# JSPatchPlaygroundTool

JSPatch天然能实现playground黑科技一样的效果，什么样的黑科技呢？我们改的每一行代码，每一个语句，完全无需重新运行app，直接能立刻看到效果。

并且bang哥已经给出了如何操作和说明

# JSPatch Playground

[JSPatch Playground Github](https://github.com/bang590/JSPatch/tree/master/Demo/iOSPlayground)


![Screenshot](https://raw.github.com/bang590/JSPatch/master/Demo/iOSPlayground/Screenshot.gif)

## 介绍

JSPatch Playground 可以让你快速看到 JSPatch 代码执行效果，APP在模拟器运行后，每次修改脚本保存模拟器都会自动刷新，无需重启模拟器，即时看到效果。

你也可以仿照 JSPatch Playground 在你的项目里添加 JSPatch 脚本即时刷新功能，帮助你快速使用 JSPatch 开发功能模块。

Tips: 如果运行过程中脚本执行错误，会在状态栏里显示错误原因，点击状态栏可以看到更详细的错误提示。



# JSPatchPlaygroundTool

bang哥的Playground工程下面，可以看到想要配置这样一个如此酷炫的黑科技，[JSPatch Playground Github](https://github.com/bang590/JSPatch/tree/master/Demo/iOSPlayground) 项目下的`JPRootViewController.m`文件里面的代码还是挺多的

由于前些日子搞了一阵子ReactNative，发现ReactNative下面的Debug，Reload工具很是方便，心想也给JSPatch弄一套，于是就有了这个`JSPatchPlaygroundTool`

初衷是，把一整套playground的思路以及环境代码配置，封装成工具，以简洁的API就能轻松运行。

<!--more-->

## JSPatchPlaygroundTool的使用

这段代码分成两部分，上半部分就是配置`JSPatchPlaygroundTool`，让JSPatch以Playground的模式进行工作。下半部分则是正常代码，正常的按既有方案加载JSPatch

```objectivec
#if TARGET_IPHONE_SIMULATOR
    //playground调试
    //JS测试包的本地绝对路径
    NSString *rootPath = @"/Users/Awhisper/Desktop/Github/JSPatchPlaygroundTool/JSPatchPlaygroundDemo/JSPatchPlaygroundDemo";
    
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"js"];
    NSString *mainScriptPath = [NSString stringWithFormat:@"%@/%@", scriptRootPath, @"demo.js"];
    [JPPlayground setReloadCompleteHandler:^{
        [self showController];
    }];
    [JPPlayground startPlaygroundWithJSPath:mainScriptPath];
    
#else
    //正常执行JSPatch
    //JS测试包的本地绝对路径
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    
    NSString *scriptPath = [rootPath stringByAppendingPathComponent:@"demo.js"];
    NSString *script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];
#endif
    
```

这里只讲解上半部分的API，`rootPath`此处切记输入Mac电脑的mainJS文件所在的路径，我的目录里在工程文件`JSPatchPlaygroundDemo`下专门放了个名字为JS的文件夹，里面放着核心的JS代码逻辑，所以我又补充了`\js\demo.js`作为后缀

- [JPPlayground setReloadCompleteHandler:block]

这个API的意义在于，每次重新刷新JS后，如果有一些额外的想要操作的东西就可以在此时执行，如果没有，这个API完全可以不使用

- [JPPlayground startPlaygroundWithJSPath:path]


这个API是核心API，输入mainJS的路径后，整个JSPatch将会以playground的模式进行运行

## JSPatchPlaygroundTool的效果

__command + X__:可以打开操作菜单

![menu](http://ww2.sinaimg.cn/mw690/678c3e91jw1f6lkzh8zwdj208n0fyaam.jpg)


__command + R__:可以ReloadJS

当APP在保持运行的时候，我们可以任意修改main.js文件然后进行保存，然后按command+R的组合键，就可以立刻刷新

__JS Error__:当JS文件有错误，app并不会崩溃，保持持续运行，并且弹出红色界面，详细描述错误信息，当把js文件修改正确后，重新reload，自然就会顺利运行。

![error](http://ww2.sinaimg.cn/mw690/678c3e91jw1f6lkzglfruj208n0fyq3t.jpg)

__AutoReload JS__:Tool可以开启监听JS文件的变化，当你把menu中的这个开关打开，每一次修改js文件进行保存，都会自动触发reload。再次点击这个按钮，会关闭监听，（AutoReload默认不开启）

__Todo List__:我还想尝试在菜单里面多做2个功能，但并未能找到办法

- 自动打开Finder，打开JS文件所在的目录，从而能快速找到要修改的JS文件，轻轻松松的开始畅快的JS代码之旅，从此告别编译，运行，重启app的烦躁过程

- 自动打开Safari的开发者模式，打开正在run的JSContext，从而能对js代码进行断点调试，就好像ReactNative能自动打开chrome一样

我没有找到很好的办法，能在iOS框架里面，在模拟器里面，打开Mac上的Mac app，太多的方法都是OSX开发才能使用的库，比如`NSWorkSpace`，这玩意没法在iOS项目里用。发愁

## JSPatchPlaygroundTool的目标

当使用JSPatch进行一整个功能模块的开发，而不仅仅是只用来修改bug，能像ReactNative一样，run起app后，告别反锁的编译，运行，写出来的代码立刻就生效，代码出错也立刻报出来，丝毫不影响运行，重新修改好后，自然完美运作。

# JSPatchPlayground的原理

之前提到过JSPatch是天然支持这种playground的黑科技玩法的~

原因就在于JSPatch的一个Extension`JPCleaner`，他可以让所有被JSPatch的hook的函数都恢复原样，这样将修改过最新的JS，重新执行以下，就实现了Reload的效果