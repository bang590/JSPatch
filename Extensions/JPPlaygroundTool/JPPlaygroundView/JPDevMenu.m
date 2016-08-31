//
//  JPPlaygroundMenu.m
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "JPDevMenu.h"
#import <UIKit/UIKit.h>

@interface JPDevMenuItem : NSObject

/**
 * This creates an item with a simple push-button interface, used to trigger an
 * action.
 */
+ (instancetype)buttonItemWithTitle:(NSString *)title
                            handler:(void(^)(void))handler;

/**
 * This creates an item with a toggle behavior. The key is used to store the
 * state of the toggle. For toggle items, the handler will be called immediately
 * after the item is added if the item was already selected when the module was
 * last loaded.
 */
+ (instancetype)toggleItemWithKey:(NSString *)key
                            title:(NSString *)title
                    selectedTitle:(NSString *)selectedTitle
                          handler:(void(^)(BOOL selected))handler;
@end

typedef NS_ENUM(NSInteger, JPDevMenuType) {
    JPDevMenuTypeButton,
    JPDevMenuTypeToggle
};

@interface JPDevMenuItem ()

@property (nonatomic, assign, readonly) JPDevMenuType type;
@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *selectedTitle;
@property (nonatomic, copy) id value;

@end

@implementation JPDevMenuItem
{
    id _handler; // block
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (instancetype)initWithType:(JPDevMenuType)type
                         key:(NSString *)key
                       title:(NSString *)title
               selectedTitle:(NSString *)selectedTitle
                     handler:(id /* block */)handler
{
    if ((self = [super init])) {
        _type = type;
        _key = [key copy];
        _title = [title copy];
        _selectedTitle = [selectedTitle copy];
        _handler = [handler copy];
        _value = nil;
    }
    return self;
}

+ (instancetype)buttonItemWithTitle:(NSString *)title
                            handler:(void (^)(void))handler
{
    return [[self alloc] initWithType:JPDevMenuTypeButton
                                  key:nil
                                title:title
                        selectedTitle:nil
                              handler:handler];
}

+ (instancetype)toggleItemWithKey:(NSString *)key
                            title:(NSString *)title
                    selectedTitle:(NSString *)selectedTitle
                          handler:(void (^)(BOOL selected))handler
{
    return [[self alloc] initWithType:JPDevMenuTypeToggle
                                  key:key
                                title:title
                        selectedTitle:selectedTitle
                              handler:handler];
}

- (void)callHandler
{
    switch (_type) {
        case JPDevMenuTypeButton: {
            if (_handler) {
                ((void(^)())_handler)();
            }
            break;
        }
        case JPDevMenuTypeToggle: {
            if (_handler) {
                ((void(^)(BOOL selected))_handler)([_value boolValue]);
            }
            break;
        }
    }
}

@end

@interface JPDevMenu ()<UIActionSheetDelegate>

@property (nonatomic,strong) UIActionSheet * actionSheet;
@property (nonatomic,strong) NSMutableDictionary *settings;
@property (nonatomic,strong) NSArray<JPDevMenuItem *> *presentedItems;

@end

@implementation JPDevMenu

-(instancetype)init
{
    self = [super init];
    if (self) {
        _settings = [[NSMutableDictionary alloc]init];
    }
    return self;
}


- (NSArray<JPDevMenuItem *> *)menuItems
{
    NSMutableArray<JPDevMenuItem *> *items = [NSMutableArray new];
    
    // Add built-in items
    
    
    [items addObject:[JPDevMenuItem buttonItemWithTitle:@"Reload JS (Command+R)" handler:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(devMenuDidAction:withValue:)]) {
            [self.delegate devMenuDidAction:JPDevMenuActionReload withValue:nil];
        }
    }]];
    
    JPDevMenuItem *toggle = [JPDevMenuItem toggleItemWithKey:@"autoReloadJS" title:@"open Auto Reload JS" selectedTitle:@"Auto Reload JS Is Open" handler:^(BOOL selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(devMenuDidAction:withValue:)]) {
            [self.delegate devMenuDidAction:JPDevMenuActionAutoReload withValue:@(selected)];
        }
        
    }];
    toggle.value = _settings[@"autoReloadJS"];
    [items addObject:toggle];
    
    
    [items addObject:[JPDevMenuItem buttonItemWithTitle:@"Help" handler:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(devMenuDidAction:withValue:)]) {
            [self.delegate devMenuDidAction:JPDevMenuActionOpenJS withValue:nil];
        }
    }]];
    
    
    return items;
}


- (void)toggle
{
    if (_actionSheet) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
        _actionSheet = nil;
    } else {
        [self show];
    }
    
}

-(void)show
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    actionSheet.title = @"JPatch Playgournd : Command + X";
    actionSheet.delegate = self;
    
    NSArray<JPDevMenuItem *> *items = [self menuItems];
    for (JPDevMenuItem *item in items) {
        switch (item.type) {
            case JPDevMenuTypeButton: {
                [actionSheet addButtonWithTitle:item.title];
                break;
            }
            case JPDevMenuTypeToggle: {
                BOOL selected = [item.value boolValue];
                [actionSheet addButtonWithTitle:selected? item.selectedTitle : item.title];
                break;
            }
        }
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    _actionSheet = actionSheet;
    _presentedItems = items;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _actionSheet = nil;
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    JPDevMenuItem *item = _presentedItems[buttonIndex];
    switch (item.type) {
        case JPDevMenuTypeButton: {
            [item callHandler];
            break;
        }
        case JPDevMenuTypeToggle: {
            BOOL value = [_settings[item.key] boolValue];
            [self updateSetting:item.key value:@(!value)]; // will call handler
            break;
        }
    }
    return;
}

- (void)updateSetting:(NSString *)name value:(id)value
{
    // Fire handler for item whose values has changed
    for (JPDevMenuItem *item in _presentedItems) {
        if ([item.key isEqualToString:name]) {
            if (value != item.value && ![value isEqual:item.value]) {
                item.value = value;
                [item callHandler];
            }
            break;
        }
    }
    
    // Save the setting
    id currentValue = _settings[name];
    if (currentValue == value || [currentValue isEqual:value]) {
        return;
    }
    if (value) {
        _settings[name] = value;
    } else {
        [_settings removeObjectForKey:name];
    }
}



-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(devMenuDidAction:withValue:)]) {
        [self.delegate devMenuDidAction:JPDevMenuActionCancel withValue:nil];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(devMenuDidAction:withValue:)]) {
        [self.delegate devMenuDidAction:JPDevMenuActionCancel withValue:nil];
    }
}

#pragma clang diagnostic pop

@end
