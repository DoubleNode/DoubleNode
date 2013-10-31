//
//  DNAppConstants.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Provides access to App-specific constants, specified in a plist file specified by the 'Constants_plist' setting in the App's main *-Info.plst file.
 */
@interface DNAppConstants : NSObject

#pragma mark - Constant plist to object functions

/**
 *  Creates and returns a UIColor object, initialized with the NSString loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new UIColor object, configured according to the value in the Constants plist file.
 */
+ (UIColor*)colorConstant:(NSString*)key;

/**
 *  Returns a BOOL value, initialized with the boolValue of the NSString loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A BOOL value, configured according to the boolValue of the NSString in the Constants plist file.
 */
+ (BOOL)boolConstant:(NSString*)key;

/**
 *  Returns a double value, initialized with the doubleValue of the NSString loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A double value, configured according to the boolValue of the NSString in the Constants plist file.
 */
+ (double)doubleConstant:(NSString*)key;

/**
 *  Creates and returns a UIFont object, initialized with the NSString objects loaded from the Constants plist file for the specified key.
 *
 *  @discussion key + Name is the generated key for loading the font postscript name.
 *  @discussion key + Size is the generated key for loading the font size in "retina" points.  This value is automatically divided by 2 before being used.  This allows you to pull the font size points directly from a retina-sized Photoshop file.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new UIFont object, configured according to the value in the Constants plist file.
 */
+ (UIFont*)fontConstant:(NSString*)key;

/**
 *  Returns a CGSize value, initialized with the floatValue of the NSString objects loaded from the Constants plist file for the specified key.
 *
 *  @discussion key + Width is the generated key for loading the width.
 *  @discussion key + Height is the generated key for loading the height.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new CGSize value, configured according to the value in the Constants plist file.
 */
+ (CGSize)sizeConstant:(NSString*)key;

#pragma mark - Low-level functions

/**
 *  Creates and returns a NSString object, initialized with the NSString object loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new NSString object, configured according to the value in the Constants plist file.
 */
+ (id)constantValue:(NSString*)key;

/**
 *  Returns the NSDictionary of a plist file (loaded the first time) specified by the 'Constants_plist' setting in the App's main *-Info.plst file.
 *
 *  @return A new NSDictionary object, loaded with all of the keys/values in the Constants plist file.
 */
+ (NSDictionary*)plistDict;

/**
 *  Returns a NSObject object, initialized with the object loaded from the Constants plist file for the specified key.  If the specified key doesn't exist, a warning message is logged to the console.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new NSString object, configured according to the value in the Constants plist file.
 */
+ (id)plistConfig:(NSString*)key;

@end
