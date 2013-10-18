//
//  DNAppDelegate.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DNApplicationDelegate<NSObject>

- (void)disableURLCache;

- (void)setDoNotUseIncrementalStore:(BOOL)flagValue;
- (void)setPersistentStorePrefix:(NSString*)prefix;
- (NSManagedObjectContext*)managedObjectContext;
- (NSManagedObjectModel*)managedObjectModel;
- (void)deletePersistentStore;
- (void)saveContext;

- (id)settingsItem:(NSString*)item;
- (id)settingsItem:(NSString*)item default:(id)defaultValue;
- (id)settingsItem:(NSString*)item boolDefault:(BOOL)defaultValue;
- (void)setSettingsItem:(NSString*)item value:(id)value;
- (void)setSettingsItem:(NSString*)item boolValue:(BOOL)value;

@end

