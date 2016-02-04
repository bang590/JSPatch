//
//  AppDelegate.m
//  JSPatchOSXDemo
//
//  Created by Felix Deimel on 26.05.15.
//  Copyright (c) 2015 Lemon Mojo. All rights reserved.
//

#import "AppDelegate.h"
#import "JPEngine.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [JPEngine startEngine];
    
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    
    [JPEngine evaluateScript:script];
}

// Implemented in demo.js
- (IBAction)buttonJavaScriptTestAction:(id)sender { }

- (IBAction)buttonObjectiveCTestAction:(id)sender
{
    self.clickCount++;
    
    [(NSButton*)sender setTitle:[NSString stringWithFormat:@"Clicked %i times", self.clickCount]];
    
    [self.tableView reloadData];
}

// Implemented in demo.js
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { return 0; }

// Implemented in demo.js
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row { return nil; }

@end
