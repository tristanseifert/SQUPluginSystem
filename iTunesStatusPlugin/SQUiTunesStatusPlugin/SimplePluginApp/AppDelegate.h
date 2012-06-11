//
//  AppDelegate.h
//  SimplePluginApp
//
//  Created by Tristan Seifert on 11/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SQUPluginManager.h"
#import "OnOffSwitchControlCell.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    // plugin outlets    
    IBOutlet OnOffSwitchControlCell *pluginsOnToggle;
    IBOutlet NSTextField *plugin_title;
    IBOutlet NSTextField *plugin_author;
    IBOutlet NSTextField *plugin_desc;
    IBOutlet NSImageView *plugin_image;
    IBOutlet NSButton *plugin_uninstallBtn;
    IBOutlet NSView *plugin_uiHolder;
    IBOutlet NSTableView *plugin_pluginList;
    IBOutlet NSScrollView *plugin_pluginContentView;
    NSInteger pluginState;
    NSImage *questionMarkImage;
    
    IBOutlet NSWindow *plugin_install_window;
    IBOutlet NSTextField *plugin_install_title;
    IBOutlet NSTextField *plugin_install_author;
    IBOutlet NSImageView *plugin_install_icon;
    IBOutlet NSTextView *plugin_install_info;
    IBOutlet NSProgressIndicator *plugin_install_progress;
    IBOutlet NSTextField *plugin_install_progress_text;
    IBOutlet NSButton *plugin_install_ok;
    IBOutlet NSButton *plugin_install_cancel;
    IBOutlet NSWindow *plugin_install_progressWindow;
    IBOutlet NSButton *plugin_install_progressCancel;
    
    NSString *installPluginPath;
}

- (IBAction) pluginSwitchToggled:(id) sender;
- (IBAction) pluginUninstallPressed:(id) sender;

- (IBAction) plugin_install_ok:(id)sender;
- (IBAction) plugin_install_cancel:(id)sender;
- (IBAction) plugin_install_cancel_progress:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
