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

/**
 *  <#Description#>
 */
- (void)disableURLCache;

/**
 *  <#Description#>
 *
 *  @param flagValue <#flagValue description#>
 */
- (void)setDoNotUseIncrementalStore:(BOOL)flagValue;

/**
 *  <#Description#>
 *
 *  @param prefix <#prefix description#>
 */
- (void)setPersistentStorePrefix:(NSString*)prefix;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSManagedObjectContext*)managedObjectContext;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSManagedObjectModel*)managedObjectModel;

/**
 *  <#Description#>
 */
- (void)deletePersistentStore;

/**
 *  <#Description#>
 */
- (void)saveContext;

/**
 *  <#Description#>
 *
 *  @param item <#item description#>
 *
 *  @return <#return value description#>
 */
- (id)settingsItem:(NSString*)item;

/**
 *  <#Description#>
 *
 *  @param item         <#item description#>
 *  @param defaultValue <#defaultValue description#>
 *
 *  @return <#return value description#>
 */
- (id)settingsItem:(NSString*)item default:(id)defaultValue;

/**
 *  <#Description#>
 *
 *  @param item         <#item description#>
 *  @param defaultValue <#defaultValue description#>
 *
 *  @return <#return value description#>
 */
- (id)settingsItem:(NSString*)item boolDefault:(BOOL)defaultValue;

/**
 *  <#Description#>
 *
 *  @param item  <#item description#>
 *  @param value <#value description#>
 */
- (void)setSettingsItem:(NSString*)item value:(id)value;

/**
 *  <#Description#>
 *
 *  @param item  <#item description#>
 *  @param value <#value description#>
 */
- (void)setSettingsItem:(NSString*)item boolValue:(BOOL)value;

@end

