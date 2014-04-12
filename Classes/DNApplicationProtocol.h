//
//  DNApplicationProtocol.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Provides functions expected to be in the applications AppDelegate class.
 */
@protocol DNApplicationProtocol<NSObject>

#pragma mark - Base DNApplicationProtocol functions

@optional

/**
 *  Hook to setup initial debug logging state
 *
 *  @discussion The primary use-case for this function is for debugging, diagnostics and unit testing.
 *
 */
- (void)resetLogState;

@required

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

