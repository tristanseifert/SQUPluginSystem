//
//  AppDelegate.m
//  SimplePluginApp
//
//  Created by Tristan Seifert on 11/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc {
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL success = NO;
    
    NSArray *directoriesToCreate = [NSArray arrayWithObjects:@"Plugins", @"Plugin Data", nil];
    
    for (NSString *folder in directoriesToCreate) {
        success = NO;
        error = nil;
        
        if(![fm fileExistsAtPath:[[fm applicationSupportDirectory] stringByAppendingPathComponent:folder]]) {
            success = [fm createDirectoryAtPath:[[fm applicationSupportDirectory] stringByAppendingPathComponent:folder] withIntermediateDirectories:YES attributes:nil error:&error];
            
            if(!success || error != nil) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
                [[NSApplication sharedApplication] stop:nil];
            }
        }
    }
    
    // this will scan all directories for plugins
    [[SQUPluginManager sharedManager] loadPlugins];
    // this will attempt to load all found plugins
    [[SQUPluginManager sharedManager] instantiatePlugins]; 
    
    pluginsOnToggle.state = [[NSUserDefaults standardUserDefaults] integerForKey:@"pluginsEnabled"];
    pluginState = pluginsOnToggle.state;
    
	[self.window center];
	[self.window makeKeyAndOrderFront:nil];
    
    [plugin_pluginList registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [plugin_pluginList reloadData];
}



#pragma mark -
#pragma mark Plugin shenanigans

- (IBAction) pluginSwitchToggled:(id) sender {
    NSLog(@"Selected state: %ld", pluginsOnToggle.state);
    //if(pluginState == pluginsOnToggle.state) return;
    
    pluginState = pluginsOnToggle.state;
    
    if(pluginsOnToggle.state == 1) {
        [plugin_uiHolder setHidden:NO];
        CGRect windowRect = self.window.frame;
        CGRect frame = CGRectMake(windowRect.origin.x, windowRect.origin.y - 372, windowRect.size.width, windowRect.size.height + 372);
        [self.window setFrame:frame display:YES animate:YES];
    } else {
        [plugin_uiHolder setHidden:YES];
        CGRect windowRect = self.window.frame;
        CGRect frame = CGRectMake(windowRect.origin.x, windowRect.origin.y + 372, windowRect.size.width, windowRect.size.height - 372);
        [self.window setFrame:frame display:YES animate:YES];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:pluginsOnToggle.state forKey:@"pluginsEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) pluginUninstallPressed:(id) sender {
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"supressPluginUninstallAlert"]) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Are you sure you want to uninstall this plugin?", nil) defaultButton:NSLocalizedString(@"Cancel", nil) alternateButton:NSLocalizedString(@"Uninstall", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"If you uninstall a plugin, all of it's settings and data will be lost.", nil)];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setShowsSuppressionButton:YES];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(uninstallPluginAlertDidEnd:returnCode:contextInfo:) contextInfo:[NSNumber numberWithInt:plugin_pluginList.selectedRow]];
    }
}

- (void)uninstallPluginAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[NSUserDefaults standardUserDefaults] setBool:[alert suppressionButton].state forKey:@"supressPluginUninstallAlert"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(returnCode == NSAlertAlternateReturn) {
        NSLog(@"Uninstall Plugin: %i", (int) [(NSNumber *)contextInfo intValue]);
    }
}

#pragma mark Table View delegate and data source for plugin shenanigans

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [SQUPluginManager sharedManager].pluginInstances.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSObject<SQUPluginProtocol> *plugin = [[SQUPluginManager sharedManager].pluginInstances objectAtIndex:rowIndex];
    
    if([aTableColumn.identifier isEqualToString:@"image"]) {
        if([plugin pluginIcon] == nil) {
            if(questionMarkImage == nil) {
                OSType code = UTGetOSTypeFromString((CFStringRef)@"ques");
                questionMarkImage = [[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(code)] retain];
            }
            
            return questionMarkImage;
        } else {
            return [plugin pluginIcon];
        }
    } else if([aTableColumn.identifier isEqualToString:@"name"]) {
        return [[plugin pluginInformation] objectForKey:kPluginInfoTitle];
    }
    
    return @"";
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if(plugin_pluginList.selectedRow != -1 && plugin_pluginList.selectedRow < [SQUPluginManager sharedManager].pluginInstances.count) {
        NSObject<SQUPluginProtocol> *plugin = [[SQUPluginManager sharedManager].pluginInstances objectAtIndex:plugin_pluginList.selectedRow];
        
        if([plugin pluginIcon] == nil) {
            if(questionMarkImage == nil) {
                OSType code = UTGetOSTypeFromString((CFStringRef)@"ques");
                questionMarkImage = [[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(code)] retain];
            }
            
            plugin_image.image = questionMarkImage;
        } else {
            plugin_image.image = [plugin pluginIcon];
        }
        
        NSDictionary *pluginInfo = [plugin pluginInformation];
        plugin_author.stringValue = [pluginInfo objectForKey:kPluginInfoAuthor];
        plugin_title.stringValue = [pluginInfo objectForKey:kPluginInfoTitle];
        plugin_desc.stringValue = [pluginInfo objectForKey:kPluginInfoDescription];
        [plugin_uninstallBtn setEnabled:YES];
        
        for (NSView *view in plugin_pluginContentView.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        if([plugin providesPreferenceView]) {
            [plugin_pluginContentView setDocumentView:[plugin preferenceView]];
            [plugin_pluginContentView.contentView scrollToPoint:NSMakePoint(0, ((NSView*)plugin_pluginContentView.documentView).frame.size.height - plugin_pluginContentView.contentSize.height)];
        }
        
        [plugin_uninstallBtn setEnabled:YES];
        
    } else {
        plugin_author.stringValue = @"";
        plugin_title.stringValue = @"";
        plugin_desc.stringValue = @"";
        plugin_image.image = nil;
        [plugin_uninstallBtn setEnabled:NO];
        plugin_uninstallBtn.toolTip = @"";
        
        for (NSView *view in plugin_pluginContentView.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    return NO;
}
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
    [tv setDropRow:-1 dropOperation:NSTableViewDropOn];
    
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    BOOL result = YES;
    
    if([[[info draggingPasteboard] propertyListForType:NSFilenamesPboardType] count] != 1) {
        return NO;
    }
    
    NSString *path = [[[info draggingPasteboard] propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
    installPluginPath = [path retain];
    
    NSLog(@"%@", path);
    
    if(![path hasSuffix:@"teleplugin"]) {
        result = NO;
    }
    
    if(result) {
        NSDictionary *pluginInfo;
        NSArray *requiredPrivileges;
        
        NSBundle* pluginBundle = [NSBundle bundleWithPath:path];                        // load plugin bundle
        
        if (pluginBundle && [pluginBundle infoDictionary] && [[pluginBundle infoDictionary] objectForKey:@"NSPrincipalClass"] != nil) {
            NSDictionary* pluginDict = [pluginBundle infoDictionary];                   // get plugin info
            
            
            NSString* folderPath = [[NSBundle mainBundle] builtInPlugInsPath];
            if (folderPath) {
                NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"teleplugin" inDirectory:folderPath] objectEnumerator];
                NSString* pluginPath;
                
                while ((pluginPath = [enumerator nextObject])) {
                    NSBundle *bundle = [NSBundle bundleWithPath:pluginPath];
                    if([[[bundle infoDictionary] objectForKey:kSQUPluginIdentifierKey] isEqualToString:[pluginDict objectForKey:kSQUPluginIdentifierKey]]) {
                        result = NO;
                        
                        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Plugin already loaded", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Another plugin with the same identifier is installed.", nil)];
                        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];                        
                    }
                }
            } 
            
            folderPath = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"Plugins"];
            if (folderPath) {
                NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"teleplugin" inDirectory:folderPath] objectEnumerator];
                NSString* pluginPath;
                
                while ((pluginPath = [enumerator nextObject])) {
                    NSBundle *bundle = [NSBundle bundleWithPath:pluginPath];
                    if([[[bundle infoDictionary] objectForKey:kSQUPluginIdentifierKey] isEqualToString:[pluginDict objectForKey:kSQUPluginIdentifierKey]]) {
                        result = NO;
                        
                        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Plugin already loaded", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Another plugin with the same identifier is installed.", nil)];
                        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];                        
                    }
                }
            } 
            
            NSString* pluginName = [pluginDict objectForKey:@"NSPrincipalClass"];       // get the main class of the plugin
            
            if (pluginName) {                                                           // check if the plist is proper
                Class pluginClass = NSClassFromString(pluginName);                      // check if class is loaded
                if (!pluginClass) {    
                    requiredPrivileges = [[pluginBundle infoDictionary] objectForKey:kSQUPluginPermissionsKey];
                    pluginInfo = [[pluginBundle infoDictionary] objectForKey:kSQUPluginInfoKey];
                } else {
                    result = NO;
                    
                    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Plugin already loaded", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The plugin you tried to install is already loaded and installed. If the plugins are not the same, please contact the plugin authors.", nil)];
                    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                }
            }
        } else {
            result = NO;
            
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Invalid Plugin", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The plugin you tried to install may be invalid or damaged. Please try re-downloading it.", nil)];
            [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        }
        
        if(result == YES) {
            NSDictionary *privilegeToName = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"privileges_text_map_en" ofType:@"plist"]];
            
            NSString *pathToIcon = [pluginBundle pathForResource:[[pluginBundle infoDictionary] objectForKey:kSQUPluginIconKey] ofType:@"icns"];
            
            plugin_install_icon.image = [[NSImage alloc] initWithContentsOfFile:pathToIcon];
            plugin_install_title.stringValue = [pluginInfo objectForKey:kPluginInfoTitle];
            plugin_install_author.stringValue = [NSString stringWithFormat:NSLocalizedString(@"By %@", nil), [pluginInfo objectForKey:kPluginInfoAuthor]];
            
            NSString *thePlainText = @"<!doctype html><html><head><style>body{font-family: Lucida Grande, Helvetica, sans-serif;}</style></head><body>";
            thePlainText = [thePlainText stringByAppendingString:NSLocalizedString(@"<p>Before installing this plugin, please make sure that all required permissions below seem to look fine. Only install this plugin if you trust it's publisher.</p><strong>Description:</strong><br />", nil)];
            thePlainText = [thePlainText stringByAppendingFormat:NSLocalizedString(@"<p>%@</p><strong>Required Privileges:</strong><br /><li>", nil), [pluginInfo objectForKey:kPluginInfoDescription]];
            
            for (NSString *privilege in requiredPrivileges) {
                NSString *humanPrivilege = [privilegeToName objectForKey:privilege];
                
                if(humanPrivilege != nil) {
                    thePlainText = [thePlainText stringByAppendingFormat:@"<ul>%@</ul>", humanPrivilege];
                } else {
                    thePlainText = [thePlainText stringByAppendingFormat:@"<ul>%@</ul>", privilege];                    
                }
            }
            
            thePlainText = [thePlainText stringByAppendingString:@"</li>"];
            thePlainText = [thePlainText stringByAppendingString:NSLocalizedString(@"<br /><p>If you are sure you want to install this plugin, click the \"Install Plugin\" button below.</p>", nil)];            
            thePlainText = [thePlainText stringByAppendingString:@"</body></html>"];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithHTML:[thePlainText dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:NULL];
            [[plugin_install_info textStorage] setAttributedString:text];
            
            [NSApp beginSheet:plugin_install_window modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
            
            privilegeToName = nil;
        }
        
    }
    
    return result;
}


- (IBAction) plugin_install_ok:(id)sender {
    [plugin_install_window orderOut:sender];
    [NSApp endSheet:plugin_install_window];
    
    [plugin_install_progress setIndeterminate:YES];
    [plugin_install_progress_text setStringValue:NSLocalizedString(@"Copying to plugins folder...", nil)];
    [plugin_install_progress startAnimation:sender];
    
    [NSApp beginSheet:plugin_install_progressWindow modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    
    NSString *path = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"PlugIns"];
    [[NSFileManager defaultManager] copyItemAtPath:installPluginPath toPath:path error:nil];
    
    [plugin_pluginList reloadData];
    [plugin_install_progressWindow orderOut:sender];
    [NSApp endSheet:plugin_install_progressWindow];
    
    [self.window makeKeyAndOrderFront:sender];
}

- (IBAction) plugin_install_cancel:(id)sender {
    [plugin_install_window orderOut:sender];
    [NSApp endSheet:plugin_install_window];
}

- (IBAction) plugin_install_cancel_progress:(id)sender {
    [plugin_install_progressWindow orderOut:sender];
    [NSApp endSheet:plugin_install_progressWindow];
    
    [self.window makeKeyAndOrderFront:sender];
}

@end
