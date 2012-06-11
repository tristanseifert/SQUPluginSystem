//
//  SQUUtilities.h
//  Teletype
//
//  Created by Tristan Seifert on 08/06/2012.
//  Copyright (c) 2012 Squee! Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQUUtilities : NSObject

@end

#pragma mark -
#pragma mark NSFileManager Category

@interface NSFileManager (DirectoryLocations)

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory inDomain:(NSSearchPathDomainMask)domainMask appendPathComponent:(NSString *)appendComponent error:(NSError **)errorOut;
- (NSString *)applicationSupportDirectory;

@end
