//
//  SQUiTunesPlugin.h
//  Teletype
//
//  Created by Tristan Seifert on 09/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SQUPluginProtocol.h>
#import <SQUPluginManager.h>

#import "iTunes.h"

@interface SQUiTunesPlugin : NSObject  <SQUPluginProtocol> {
    IBOutlet NSView *prefView;
    
    IBOutlet NSTokenField *format;
    IBOutlet NSTextField *preview;
    IBOutlet NSButton *enabled;
    IBOutlet NSStepper *updateInterval;
    IBOutlet NSTextField *updateIntervalView;
    
    NSMutableDictionary *preferences;
    
    iTunesApplication *iTunesScriptBridge;
    NSTimer *timer;
    
    NSString *previousStatus;
}

- (IBAction) toggleOnOff:(id)sender;
- (IBAction) updateIntervalChanged:(id) sender;
- (IBAction) formatChanged:(id)sender;

@end
