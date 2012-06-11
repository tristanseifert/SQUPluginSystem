//
//  SQUPluginProtocol.h
//  Teletype
//
//  Created by Tristan Seifert on 09/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kPluginInfoTitle @"title"               // required
#define kPluginInfoAuthor @"author"             // required
#define kPluginInfoVersion @"version"           // required
#define kPluginInfoDescription @"description"   // required
#define kPluginInfoBuild @"build"
#define kPluginInfoCopyright @"copyright"

#define kSQUPluginIdentifierKey @"SQUPluginUUID"
#define kSQUPluginIconKey @"SQUPluginIcon"
#define kSQUPluginInfoKey @"SQUPluginInfo"
#define kSQUPluginPermissionsKey @"SQUPluginPermission"

#define kSQUPluginActionUpdateStatus @"statusUpdate"
#define kSQUPluginActionGetStatus @"statusFetch"

#define kSQUReturnDataKeyStatus @"status"

// different privileges a plugin may request.

#define kPluginPrivilegeUpdateStatus    @"updateStatus"
#define kPluginPrivilegeSendMessage     @"sendMsg"
#define kPluginPrivilegeSeeMessage      @"seeMsg"
#define kPluginPrivilegeChangeProfile   @"changeProfile"

// an enum of different events the application sends — also encapsulated in the user
// info dict of a notification that is sent, if the plugin subscribes to it.

typedef enum kSQUPluginEvent {
    kEventLoggedOn,
    kEventMessageReceived,
    kEventMessageSent,
    kEventCallStarted,
    kEventCallEnded,
    kEventContactRequestSent,
    kEventContactRequestReceived,
    kEventExportLog,
    kEventProfileChanged,
    kEventContactRemoved,
    kEventContactIgnored,
    kEventContactUnignored,
    kEventContactRenamed,
    kEventChatSendFile,
    kEventUserAddedToChat,
    kEventUserAddedToCall,
    kEventUserExitedCall,
    kEventUserExitedChat,
    kEventGroupChatInvited,
    kEventGroupCallInvited,
    kEventGroupUserPrivilegeChange,
    kEventContactUpdated,
    kEventSearchHistory,
    kEventSearchHistoryResult,
    kEventSearchForUser,
    kEventSearchForUserResults,
    kEventAboutToQuit,
    kEventSignedOut,
    kEventSignedIn
    } kSQUPluginEvent;

@protocol SQUPluginProtocol <NSObject>

@required

+ (BOOL) initializeClass:(NSBundle *) bundle;
+ (void) terminateClass;
+ (NSEnumerator*) pluginsFor:(id)anObject;

- (NSDictionary *) pluginInformation;
- (NSArray *) requiredPrivileges;

- (NSImage *) pluginIcon;
- (BOOL) providesPreferenceView;
- (NSView *) preferenceView;

- (NSString *) pluginIdentifier;

@optional

- (void) shutDownPlugin;
- (void) setUpPlugin;
- (void) checkForUpdate;
- (void) teletypeEventOccurred:(kSQUPluginEvent) event withUserInfo:(void *) info;

@end
