//
//  SQUiTunesPlugin.m
//  Teletype
//
//  Created by Tristan Seifert on 09/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import "SQUiTunesPlugin.h"

static NSBundle* SQUiTunesPlugin_pluginBundle = nil;

@implementation SQUiTunesPlugin

+ (BOOL) initializeClass:(NSBundle *) bundle {
    if (SQUiTunesPlugin_pluginBundle) {
        return NO;
    }
    
    SQUiTunesPlugin_pluginBundle = [bundle retain];
    return YES;    
}

+ (void) terminateClass {
    [SQUiTunesPlugin_pluginBundle release];
    SQUiTunesPlugin_pluginBundle = nil;
}

+ (NSEnumerator*) pluginsFor:(id)anObject {
    NSMutableArray* plugs = [[[NSMutableArray alloc] init] autorelease];
    
    SQUiTunesPlugin* instance = [[[SQUiTunesPlugin alloc] init] autorelease];
    if (instance && [NSBundle loadNibNamed:@"SQUiTunesPrefUI" owner:instance] && [instance preferenceView]) {
        [plugs addObject:instance];
    }
    
    return [plugs count]?[plugs objectEnumerator]:nil;
}

- (void) setUpPlugin {
    Class pluginManager = NSClassFromString(@"SQUPluginManager");
    NSString *pathToPluginData = [[pluginManager sharedManager] getPluginDirectoryForPlugin:self];
    NSLog(@"Path to plugin data: %@", pathToPluginData);
    
    preferences = [[[NSMutableDictionary alloc] initWithContentsOfFile:[pathToPluginData stringByAppendingPathComponent:@"prefs.plist"]] retain];
    
    if(!preferences) {
        preferences = [[[NSMutableDictionary alloc] initWithContentsOfFile:[SQUiTunesPlugin_pluginBundle pathForResource:@"defaults" ofType:@"plist"]] retain];
        [preferences writeToFile:[pathToPluginData stringByAppendingPathComponent:@"prefs.plist"] atomically:YES];
    }
    
    format.stringValue = [preferences objectForKey:@"statusFormat"];
    enabled.state = [[preferences objectForKey:@"statusUpdatesEnabled"] integerValue];
    updateInterval.integerValue = [[preferences objectForKey:@"updateInterval"] integerValue];
    updateIntervalView.integerValue = [[preferences objectForKey:@"updateInterval"] integerValue];
    
    NSDictionary *dict = nil;    
    [[pluginManager sharedManager] pluginMessage:[NSDictionary dictionaryWithObjectsAndKeys:kSQUPluginActionGetStatus, @"action",  nil] withReturn:&dict];
    
    previousStatus = [[dict objectForKey:kSQUReturnDataKeyStatus] retain];
    
    if(previousStatus == nil) {
        previousStatus = @"No Status";
    }
    
    dict = nil;
    
    iTunesScriptBridge = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"] retain];
    [self timerUpdateStatus:nil];
    [self performSelectorOnMainThread:@selector(setUpTimer) withObject:nil waitUntilDone:YES];
}

- (void) setUpTimer {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrackInfo:) name:@"com.apple.iTunes.playerInfo" object:nil];
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:updateInterval.integerValue target:self selector:@selector(timerUpdateStatus:) userInfo:nil repeats:YES] retain];
}

- (void) shutDownPlugin {
    [timer invalidate];
    [timer release];
    timer = nil;
    
    [preferences setObject:format.stringValue forKey:@"statusFormat"];
    [preferences setObject:[NSNumber numberWithInteger:enabled.state] forKey:@"statusUpdatesEnabled"];
    [preferences setObject:[NSNumber numberWithInteger:updateInterval.integerValue] forKey:@"updateInterval"];
    
    Class pluginManager = NSClassFromString(@"SQUPluginManager");
    NSString *pathToPluginData = [[pluginManager sharedManager] getPluginDirectoryForPlugin:self];
    [preferences writeToFile:[pathToPluginData stringByAppendingPathComponent:@"prefs.plist"] atomically:YES];
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.apple.iTunes.playerInfo" object:nil];
}

- (NSImage *) pluginIcon {
    NSString *path = [SQUiTunesPlugin_pluginBundle pathForResource:@"itunes-file" ofType:@"icns"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
    
    return image;
}

- (NSDictionary *) pluginInformation {
    return [[SQUiTunesPlugin_pluginBundle infoDictionary] objectForKey:kSQUPluginInfoKey];
}

- (NSArray *) requiredPrivileges {
    return [[SQUiTunesPlugin_pluginBundle infoDictionary] objectForKey:kSQUPluginPermissionsKey];
}

- (BOOL) providesPreferenceView {
    return YES;
}

- (NSView *) preferenceView {
    return prefView;
}

- (NSString *) pluginIdentifier {
    return [SQUiTunesPlugin_pluginBundle objectForInfoDictionaryKey:kSQUPluginIdentifierKey];
}

#pragma mark -
#pragma mark UI Shenanigans

- (IBAction) formatChanged:(id)sender {
    [self timerUpdateStatus:nil];
}

- (IBAction) updateIntervalChanged:(id) sender {
    if(sender == updateInterval) {
        [updateIntervalView setIntegerValue:updateInterval.integerValue];
    } else {
        [updateInterval setIntegerValue:updateIntervalView.integerValue];
    }
    
    [timer invalidate];
    [timer release];
    timer = nil;
    
    [self performSelectorOnMainThread:@selector(setUpTimer) withObject:nil waitUntilDone:YES]; 
    [self timerUpdateStatus:nil];
}

- (IBAction) toggleOnOff:(id)sender {
    [format setEnabled:[sender state]];
    [updateInterval setEnabled:[sender state]];
    [updateIntervalView setEnabled:[sender state]];
    
    if([sender state] == 0) {
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.apple.iTunes.playerInfo" object:nil];
    } else {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrackInfo:) name:@"com.apple.iTunes.playerInfo" object:nil];        
    }
}

- (void) timerUpdateStatus:(NSTimer *) timer {
    [self updateTrackInfo:nil];
}

- (void) updateTrackInfo:(NSNotification *)notification {
    if([iTunesScriptBridge isRunning]) {
        iTunesTrack *currentTrack = [iTunesScriptBridge currentTrack];
        
        NSString *songTitle = [currentTrack name];
        NSString *songArtist = [currentTrack artist];
        NSString *songAlbum = [currentTrack album];
        NSString *songGenre = [currentTrack genre];
        NSString *songLength = [currentTrack time];
        NSInteger songRating = [currentTrack rating];
        
        if([songTitle isEqualToString:@"null"] || songTitle == nil) {
            [[NSClassFromString(@"SQUPluginManager") sharedManager] pluginMessage:[NSDictionary dictionaryWithObjectsAndKeys:kSQUPluginActionUpdateStatus, @"action", previousStatus, @"data", nil] withReturn:nil];  
            return;     
        } else {
            NSString *displayString = [format.stringValue stringByReplacingOccurrencesOfString:@"," withString:@""];
        
            displayString = [displayString stringByReplacingOccurrencesOfString:@"%Title%" withString:[NSString stringWithFormat:@" %@ ", songTitle]];
            displayString = [displayString stringByReplacingOccurrencesOfString:@"%Album%" withString:[NSString stringWithFormat:@" %@ ", songAlbum]];
            displayString = [displayString stringByReplacingOccurrencesOfString:@"%Artist%" withString:[NSString stringWithFormat:@" %@ ", songArtist]];
            displayString = [displayString stringByReplacingOccurrencesOfString:@"%Genre%" withString:[NSString stringWithFormat:@" %@ ", songGenre]];
            displayString = [displayString stringByReplacingOccurrencesOfString:@"%Length%" withString:[NSString stringWithFormat:@" %@ ", songLength]];
        
            NSString *ratingString = @" ";
            
            NSUInteger numberOfFullStars = songRating / 20;
        
            for (int i = 0; i < numberOfFullStars; i++) {
                ratingString = [ratingString stringByAppendingString:@"★"];
            }
        
            displayString = [displayString stringByReplacingOccurrencesOfString:@"%Rating%" withString:ratingString];
        
            preview.stringValue = displayString;  
        }      
    } else {
        [[NSClassFromString(@"SQUPluginManager") sharedManager] pluginMessage:[NSDictionary dictionaryWithObjectsAndKeys:kSQUPluginActionUpdateStatus, @"action", previousStatus, @"data", nil] withReturn:nil];  
        return;
        preview.stringValue = @"";
    }  
    
    [[NSClassFromString(@"SQUPluginManager") sharedManager] pluginMessage:[NSDictionary dictionaryWithObjectsAndKeys:kSQUPluginActionUpdateStatus, @"action", preview.stringValue, @"data", nil] withReturn:nil];  
}
             
@end
