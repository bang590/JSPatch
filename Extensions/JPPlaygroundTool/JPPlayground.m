//
//  JPPlayground.m
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "JPPlayground.h"
#import "JPKeyCommands.h"
#import "JPCleaner.h"
#import "JPDevErrorView.h"
#import "JPDevMenu.h"
#import "JPDevTipView.h"
#import "SGDirWatchdog.h"

@interface JPPlayground ()<UIActionSheetDelegate,JPDevMenuDelegate>

@property (nonatomic,strong) NSString *rootPath;

@property (nonatomic,strong) JPKeyCommands *keyManager;

@property (nonatomic,strong) UIView *errorView;

@property (nonatomic,strong) JPDevMenu *devMenu;

@property (nonatomic,assign) BOOL isAutoReloading;

@property (nonatomic,strong) NSMutableArray<SGDirWatchdog *> *watchDogs;

@end

static void (^_reloadCompleteHandler)(void) = ^void(void) {
   
};

@implementation JPPlayground

+ (instancetype)sharedInstance
{
#if TARGET_IPHONE_SIMULATOR
    static JPPlayground *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
#else
    return nil;
#endif
}

- (instancetype)init
{
    if ((self = [super init])) {
#if TARGET_IPHONE_SIMULATOR
        _keyManager = [JPKeyCommands sharedInstance];
        _devMenu = [[JPDevMenu alloc]init];
        _devMenu.delegate = self;
        _isAutoReloading = NO;
        _watchDogs = [[NSMutableArray alloc] init];
#endif
    }
    return self;
}

+(void)setReloadCompleteHandler:(void (^)())complete
{
    _reloadCompleteHandler = [complete copy];
}

+(void)startPlaygroundWithJSPath:(NSString *)path
{
    [[JPPlayground sharedInstance] startPlaygroundWithJSPath:path];
}

-(void)startPlaygroundWithJSPath:(NSString *)mainScriptPath
{
#if TARGET_IPHONE_SIMULATOR
    self.rootPath = mainScriptPath;
    
    NSString *scriptRootPath = [mainScriptPath stringByDeletingLastPathComponent];
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];
    [self watchFolder:scriptRootPath mainScriptPath:mainScriptPath];
    
    if ([scriptRootPath rangeOfString:@".app"].location != NSNotFound) {
        NSString *apphomepath = [scriptRootPath stringByDeletingLastPathComponent];
        [self watchFolder:apphomepath mainScriptPath:mainScriptPath];
    }
    
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            [self watchFolder:fullPath mainScriptPath:mainScriptPath];
        }
    }
    
    
    [JPEngine handleException:^(NSString *msg) {
        JPDevErrorView *errV = [[JPDevErrorView alloc]initError:msg];
        [[UIApplication sharedApplication].keyWindow addSubview:errV];
        self.errorView = errV;
        [self.devMenu toggle];
    }];
    
    [self.keyManager registerKeyCommandWithInput:@"x" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand *command) {
        [self.devMenu toggle];
    }];
    
    [self.keyManager registerKeyCommandWithInput:@"r" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand *command) {
        [self reload];
    }];
    
    [self reload];
#endif
}

+(void)reload
{
    [[JPPlayground sharedInstance]reload];
}

-(void)reload
{
#if TARGET_IPHONE_SIMULATOR
    [JPDevTipView showJPDevTip:@"JSPatch Reloading ..."];
    [self hideErrorView];
    [JPCleaner cleanAll];
    [JPEngine evaluateScriptWithPath:self.rootPath];
    _reloadCompleteHandler();
#endif
}

-(void)openInFinder
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"%@\n",self.rootPath);
    
    NSLog(@"请打开以上路径的文件，事实编辑JS，事实刷新");
    
    NSString *msg = [NSString stringWithFormat:@"JS文件路径：%@\n 编辑JS文件后保存，按Command+R刷新就可以看到最新的代码效果",self.rootPath];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Edit JS File and Reload" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [UIPasteboard generalPasteboard].string = self.rootPath;
    
#endif
}

-(void)watchJSFile:(BOOL)watch
{
#if TARGET_IPHONE_SIMULATOR
    for (SGDirWatchdog *dog in self.watchDogs) {
        if (watch) {
            [dog start];
        }else{
            [dog stop];
        }
    }
#endif
}

- (void)watchFolder:(NSString *)folderPath mainScriptPath:(NSString *)mainScriptPath
{
#if TARGET_IPHONE_SIMULATOR
    SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:folderPath update:^{
        [self reload];
    }];
    [self.watchDogs addObject:watchDog];
#endif
}

-(void)hideErrorView
{
#if TARGET_IPHONE_SIMULATOR
    [self.errorView removeFromSuperview];
    self.errorView = nil;
#endif
}


-(void)devMenuDidAction:(JPDevMenuAction)action withValue:(id)value
{
#if TARGET_IPHONE_SIMULATOR
    switch (action) {
        case JPDevMenuActionReload:{
            [self reload];
            break;
        }
        case JPDevMenuActionAutoReload:{
            BOOL select = [value boolValue];
            [self watchJSFile:select];
            break;
        }
        case JPDevMenuActionOpenJS:{
            [self openInFinder];
            break;
        }
        case JPDevMenuActionCancel:{
            [self hideErrorView];
            break;
        }
            
            
        default:
            break;
    }
#endif
}
@end
