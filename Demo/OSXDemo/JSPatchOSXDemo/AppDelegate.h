//
//  AppDelegate.h
//  JSPatchOSXDemo
//
//  Created by Felix Deimel on 26.05.15.
//  Copyright (c) 2015 Lemon Mojo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, readwrite) int clickCount;
@property (weak) IBOutlet NSTableView *tableView;

@end