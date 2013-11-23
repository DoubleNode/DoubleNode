//
//  DNApplicationProtocol.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Provides functions expected to be in the applications AppDelegate class.
 */
@protocol DNApplicationProtocol<NSObject>

#pragma mark - Base DNApplicationProtocol functions

/**
 *  Returns the rootViewController.
 *
 *  @return The main window's rootViewController.
 *
 */
- (UIViewController*)rootViewController;

#pragma mark - CoreData DNApplicationProtocol functions

/**
 *  Disables the App URL Cache (if applicable).
 *
 *  @discussion The primary use-case for this function is for debugging, diagnostics and unit testing.
 *
 */
- (void)disableURLCache;

/**
 *  Sets a flag to disable the use of a NSIncrementalStore (if applicable).
 *
 *  @discussion The primary use-case for this function is for debugging, diagnostics and unit testing.
 *
 *  @param flagValue A BOOL flag to specify whether or not to bypass using a NSIncrementalStore when initializing the App's CoreData NSPersistentStore.
 */
- (void)setDoNotUseIncrementalStore:(BOOL)flagValue;

/**
 *  Sets a string prefix to be used when opening and creating CoreData NSPersistentStore.
 *
 *  @discussion The primary use-case for this function is for debugging, diagnostics and unit testing.
 *
 *  @param prefix A NSString prefix to be prepended to any NSPersistentStore URLs.
 */
- (void)setPersistentStorePrefix:(NSString*)prefix;

/**
 *  Creates or (if already created) returns the App's default NSManagedObjectContext.
 *
 *  @return The App's default NSManagedObjectContext object, creating it if needed.
 */
- (NSManagedObjectContext*)managedObjectContext:(Class)modelClass;

/**
 *  Creates or (if already created) returns the App's default NSManagedObjectModel.
 *
 *  @return The App's default NSManagedObjectModel object, creating it if needed.
 */
- (NSManagedObjectModel*)managedObjectModel:(Class)modelClass;

/**
 *  Closes the App's current NSPersistentStore, then removes the file from the device.
 */
- (void)deletePersistentStore:(Class)modelClass;

/**
 *  Flushes any cached updates from the current NSManagedObjectContext to the NSPersistentStore.
 */
- (void)saveContext:(Class)modelClass;

#pragma mark - NSUserDefaults settings items

/**
 *  Loads and returns the current value of the user setting, specified by a key.
 *
 *  @param item The NSString key for the specific user setting.
 *
 *  @return The current value of the specified user setting (or @"" if not set).
 */
- (id)settingsItem:(NSString*)item;

/**
 *  Loads and returns the current value of the user setting, specified by a key and a default value.
 *
 *  @param item         The NSString key for the specific user setting.
 *  @param defaultValue The default value for the specific user setting, when it has not been previously set.
 *
 *  @return The current value of the specified user setting.
 */
- (id)settingsItem:(NSString*)item default:(id)defaultValue;

/**
 *  Loads and returns the current BOOL value of the user setting, specified by a key and a default value.
 *
 *  @param item         The NSString key for the specific user setting.
 *  @param defaultValue The default BOOL value for the specific user setting, when it has not been previously set.
 *
 *  @return The current value of the specified user setting.
 */
- (id)settingsItem:(NSString*)item boolDefault:(BOOL)defaultValue;

/**
 *  Sets the value of the user setting, specified by a key.
 *
 *  @param item  The NSString key for the specific user setting.
 *  @param value The new value for the specific user setting.
 */
- (void)setSettingsItem:(NSString*)item value:(id)value;

/**
 *  Sets the BOOL value of the user setting, specified by a key.
 *
 *  @param item  The NSString key for the specific user setting.
 *  @param value The new BOOL value for the specific user setting.
 */
- (void)setSettingsItem:(NSString*)item boolValue:(BOOL)value;

@end

