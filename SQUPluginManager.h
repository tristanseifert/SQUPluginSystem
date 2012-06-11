//
//  SQUPluginManager.h
//  Teletype
//
//  Created by Tristan Seifert on 09/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQUPluginProtocol.h"
#import "SQUUtilities.h"

@interface SQUPluginManager : NSObject {
    NSMutableArray *pluginClasses;
    NSMutableArray *pluginInstances;
}

@property (nonatomic, readwrite, retain) NSMutableArray *pluginClasses;
@property (nonatomic, readwrite, retain) NSMutableArray *pluginInstances;

+ (SQUPluginManager *) sharedManager;

- (void) activatePlugin:(NSString*)path;
- (void) loadPlugins;
- (void) instantiatePlugins;
- (void) instantiatePlugins:(Class) pluginClass;
- (void) unloadAllPlugins;

- (NSString *) getPluginDirectoryForPlugin:(NSObject<SQUPluginProtocol> *) plugin;
- (void) pluginMessage:(NSDictionary *) userInfo withReturn:(NSDictionary **) returnValue;

@end
