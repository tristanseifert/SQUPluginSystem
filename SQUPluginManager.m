//
//  SQUPluginManager.m
//  Teletype
//
//  Created by Tristan Seifert on 09/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import "SQUPluginManager.h"

static SQUPluginManager *sharedInstance = nil;

@implementation SQUPluginManager
@synthesize pluginClasses, pluginInstances;

#pragma mark Singleton shenanigans

+ (SQUPluginManager *) sharedManager {
    @synchronized (self) {
        if (sharedInstance == nil) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;    
}

- (id)init {
    @synchronized(self) {
        [super init];    
        
        pluginInstances = [[NSMutableArray alloc] init];
        pluginClasses = [[NSMutableArray alloc] init];
        
        return self;
    }
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (void)release {
    // do nothing
}

- (id)autorelease {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax; // This is sooo not zero
}


#pragma mark -
#pragma mark Plugin management

- (void) loadPlugins {
    NSString* folderPath = [[NSBundle mainBundle] builtInPlugInsPath];
    if (folderPath) {
        NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"teleplugin" inDirectory:folderPath] objectEnumerator];
        NSString* pluginPath;
        
        while ((pluginPath = [enumerator nextObject])) {
            [self activatePlugin:pluginPath];
        }
    } 
    
    folderPath = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"Plugins"];
    if (folderPath) {
        NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"teleplugin" inDirectory:folderPath] objectEnumerator];
        NSString* pluginPath;
        
        while ((pluginPath = [enumerator nextObject])) {
            [self activatePlugin:pluginPath];
        }
    }    
}

- (void) activatePlugin:(NSString*)path {
    NSBundle* pluginBundle = [NSBundle bundleWithPath:path];                        // load plugin bundle
    
    if (pluginBundle) {
        NSDictionary* pluginDict = [pluginBundle infoDictionary];                   // get plugin info
        
        NSString* pluginName = [pluginDict objectForKey:@"NSPrincipalClass"];       // get the main class of the plugin
            
        if (pluginName) {                                                           // check if the plist is proper
            Class pluginClass = NSClassFromString(pluginName);                      // check if class is loaded
            if (!pluginClass) {
                pluginClass = [pluginBundle principalClass];                        // if not, load it.
                        
                if ([pluginClass conformsToProtocol:@protocol(SQUPluginProtocol)] && [pluginClass isKindOfClass:[NSObject class]] && [pluginClass initializeClass:pluginBundle]) {
                        [pluginClasses addObject:pluginClass];                      // save the plugin instance
                }
            }
        }
    }
}

- (void) instantiatePlugins {
    NSEnumerator* enumerator = [pluginClasses objectEnumerator];                    // get the enumerator of all our plugins that qualified
    Class pluginClass;
    
    while ((pluginClass = [enumerator nextObject])) {                               // get the plugin class
        [self instantiatePlugins:pluginClass];                                      // instnatiate plugin
    }
}

- (void) instantiatePlugins:(Class) pluginClass {
    NSEnumerator* plugs = [pluginClass pluginsFor:nil];                             // get the plugins a bundle exposes
    
    NSObject<SQUPluginProtocol>* plugin;
    
    while ((plugin = [plugs nextObject])) {                                         // loop over each one of them
        [pluginInstances addObject:plugin];                                         // then create the object and store it
        
        if([plugin respondsToSelector:@selector(setUpPlugin)]) {
            [plugin setUpPlugin];
        }
    }
}

- (void) unloadAllPlugins {
    for (NSObject<SQUPluginProtocol> *plugin in pluginInstances) {
        if([plugin respondsToSelector:@selector(shutDownPlugin)]) {
            [plugin shutDownPlugin];
        }
    }
    
    [pluginInstances release];                                                      // release all the instances of plugins.
    pluginInstances = nil;
    
    NSEnumerator* enumerator;
    Class pclass;       
    
    enumerator = [pluginClasses objectEnumerator];                                  // loop over all loaded plugins
    while ((pclass = [enumerator nextObject])) {                                    // get a class
        
        [pclass terminateClass];                                                    // tell it to terminate
    }    
    
    [pluginClasses release];                                                        // release the plugin class array
    pluginClasses = nil;
}

#pragma mark -
#pragma mark Plugin to App methods

- (NSString *) getPluginDirectoryForPlugin:(NSObject<SQUPluginProtocol> *) plugin {
    NSString *path = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"Plugin Data"];
    path = [path stringByAppendingPathComponent:[plugin pluginIdentifier]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *err = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
        
        if(err) {
            NSLog(@"Couldn't create directory: %@", err);
            return nil;
        }
    }
    
    return path;
}

- (void) pluginMessage:(NSDictionary *) userInfo withReturn:(NSDictionary **) returnValue {
    //NSLog(@"%@", userInfo);
}

@end
