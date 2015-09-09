//
//  DNAppConstants.h
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
 *  Provides access to App-specific constants, specified in a plist file specified by the 'Constants_plist' setting in the App's main *-Info.plst file.
 */
@interface DNAppConstants : NSObject

#pragma mark - Constant plist to object functions

+ (NSString*)oAuthCredentialIdentifier;
+ (NSString*)apiHostname;

/**
 *  Creates and returns a NSDate object, initialized with the NSDate loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new NSDate object, configured according to the value in the Constants plist file.
 */
+ (NSDate*)dateConstant:(NSString*)key;

+ (NSDate*)dateConstant:(NSString*)key
                 filter:(NSString*)filter;

/**
 *  Creates and returns a UIColor object, initialized with the NSString loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new UIColor object, configured according to the value in the Constants plist file.
 */
+ (UIColor*)colorConstant:(NSString*)key;

+ (UIColor*)colorConstant:(NSString*)key
                   filter:(NSString*)filter;

/**
 *  Returns a BOOL value, initialized with the boolValue of the NSString loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A BOOL value, configured according to the boolValue of the NSString in the Constants plist file.
 */
+ (BOOL)boolConstant:(NSString*)key;

+ (BOOL)boolConstant:(NSString*)key
              filter:(NSString*)filter;

/**
 *  Returns a int value, initialized with the intValue of the NSString loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A int value, configured according to the intValue of the NSString in the Constants plist file.
 */
+ (int)intConstant:(NSString*)key;

+ (int)intConstant:(NSString*)key
            filter:(NSString*)filter;

/**
 *  Returns a double value, initialized with the doubleValue of the NSString loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A double value, configured according to the boolValue of the NSString in the Constants plist file.
 */
+ (double)doubleConstant:(NSString*)key;

+ (double)doubleConstant:(NSString*)key
                  filter:(NSString*)filter;

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

+ (UIFont*)fontConstant:(NSString*)key
                 filter:(NSString*)filter;

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

+ (CGSize)sizeConstant:(NSString*)key
                filter:(NSString*)filter;

/**
 *  Returns a NSDictionary object, initialized with the dictionartyValue of the NSString objects loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new NSDictionary value, configured according to the value in the Constants plist file.
 */
+ (NSDictionary*)dictionaryConstant:(NSString*)key;

#pragma mark - Low-level functions

/**
 *  Creates and returns a NSString object, initialized with the NSString object loaded from the Constants plist file for the specified key.
 *
 *  @param key The string which specifies the key to the Constants plist file.
 *
 *  @return A new NSString object, configured according to the value in the Constants plist file.
 */
+ (id)constantValue:(NSString*)key;

+ (id)constantValue:(NSString*)key
             filter:(NSString*)filter;

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
