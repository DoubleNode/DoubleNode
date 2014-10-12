//
//  DNUtilities.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoggerClient.h"

#import "DNApplicationProtocol.h"

/**
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/**
 *  DLog Logging Items and Macros
 */
#ifndef __LOGLEVEL__
#define __LOGLEVEL__    1

typedef NS_ENUM(NSInteger, LogLevel)
{
    LL_Critical = 0,
    LL_Error,
    LL_Warning,
    LL_Debug,
    LL_Info,
    LL_Everything
};

#define LD_UnitTests        @"UNITTESTS"
#define LD_General          @"GENERAL"
#define LD_Framework        @"FRAMEWORK"
#define LD_CoreData         @"COREDATA"
#define LD_CoreDataIS       @"COREDATAIS"
#define LD_ViewState        @"VIEWSTATE"
#define LD_Theming          @"THEMING"
#define LD_Location         @"LOCATION"
#define LD_Networking       @"NETWORKING"
#define LD_API              @"API"

#if !defined(DEBUG)
#define DLogMarker(marker)                      NSLog(@"%@", marker)
#define DLog(level,domain,...)                  NSLog(__VA_ARGS__)
#define DOLog(level,domain,...)                 NSLog(__VA_ARGS__)
#define DLogData(level,domain,data)             ;
#define DLogImage(...)                          ;
#define DLogTimeBlock(level,domain,title,block) block()
#define DAssertIsMainThread                     ;
#else
#define DLogMarker(marker)                      NSLog(@"%@", marker); LogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,@"%@", marker)
#define DLog(level,domain,...)                  DNLogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,__VA_ARGS__); LogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,__VA_ARGS__)
#define DOLog(level,domain,...)                 DNLogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,__VA_ARGS__)
#define DLogData(level,domain,data)             LogDataF(__FILE__,__LINE__,__FUNCTION__,domain,level,data)
#define DLogImage(level,domain,image)           LogImageDataF(__FILE__,__LINE__,__FUNCTION__,domain,level,image.size.width,image.size.height,UIImagePNGRepresentation(image))
#define DLogTimeBlock(level,domain,title,block) DNLogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,@"%@: blockTime: %f",title,DNTimeBlock(block)); LogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,@"%@: blockTime: %f",title,DNTimeBlock(block))
#define DAssertIsMainThread                     if (![NSThread isMainThread])                                                                                                                   \
                                                {                                                                                                                                               \
                                                    NSException* exception = [NSException exceptionWithName:@"DNUtilities Exception"                                                            \
                                                                                                     reason:[NSString stringWithFormat:@"Not in Main Thread"]                                   \
                                                                                                   userInfo:@{ @"FILE" : @(__FILE__), @"LINE" : @(__LINE__), @"FUNCTION" : @(__FUNCTION__) }];  \
                                                    @throw exception;                                                                                                                           \
                                                }

extern void LogImageDataF(const char *filename, int lineNumber, const char *functionName, NSString *domain, int level, int width, int height, NSData *data);

#undef assert
#if __DARWIN_UNIX03
#define assert(e)   (__builtin_expect(!(e), 0) ? (CFShow(CFSTR("assert going to fail, connect NSLogger NOW\n")), LoggerFlush(NULL,YES), __assert_rtn(__func__, __FILE__, __LINE__, #e)) : (void)0)
#else
#define assert(e)   (__builtin_expect(!(e), 0) ? (CFShow(CFSTR("assert going to fail, connect NSLogger NOW\n")), LoggerFlush(NULL,YES), __assert(#e, __FILE__, __LINE__)) : (void)0)
#endif
#endif

#endif

@interface DNUtilities : NSObject

+ (id<DNApplicationProtocol>)appDelegate;
+ (DNUtilities*)sharedInstance;

+ (CGFloat)screenHeight;
+ (CGFloat)screenWidth;
+ (BOOL)isTall;
+ (BOOL)isDeviceIPad;

+ (NSString*)applicationDocumentsDirectory;

+ (NSString*)appendNibSuffix:(NSString*)nibNameOrNil;
+ (NSString*)appendNibSuffix:(NSString*)nibNameOrNil withDefaultNib:(NSString*)defaultNib;
+ (NSString*)deviceImageName:(NSString*)name;

+ (void)runOnBackgroundThreadAfterDelay:(CGFloat)delay
                                  block:(void (^)())block;

+ (void)runOnMainThreadAsynchronouslyWithoutDeadlocking:(void (^)())block;
+ (void)runOnMainThreadWithoutDeadlocking:(void (^)())block;
+ (void)runOnBackgroundThread:(void (^)())block;
+ (void)runBlock:(void (^)())block;

+ (void)runAfterDelay:(CGFloat)delay block:(void (^)())block;
+ (void)runOnMainThreadAfterDelay:(CGFloat)delay block:(void (^)())block;

+ (void)runRepeatedlyAfterDelay:(CGFloat)delay block:(void (^)(BOOL* stop))block;
+ (void)runOnMainThreadRepeatedlyAfterDelay:(CGFloat)delay block:(void (^)(BOOL* stop))block;

+ (NSTimer*)repeatRunAfterDelay:(CGFloat)delay block:(void (^)())block;

+ (bool)canDevicePlaceAPhoneCall;

+ (void)playSound:(NSString*)name;
+ (NSString*)encodeWithHMAC_SHA1:(NSString*)data withKey:(NSString*)key;

+ (UIImage*)imageScaledForRetina:(UIImage*)image;

+ (id)settingsItem:(NSString*)item;
+ (id)settingsItem:(NSString*)item default:(id)defaultValue;
+ (BOOL)settingsItem:(NSString*)item boolDefault:(BOOL)defaultValue;
+ (void)setSettingsItem:(NSString*)item value:(id)value;
+ (void)setSettingsItem:(NSString*)item boolValue:(BOOL)value;

+ (NSString *)getIPAddress;

+ (void)updateImage:(UIImageView*)imageView
           newImage:(UIImage*)newImage;

#pragma mark - Dictionary Translation functions

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;

+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;
+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;

+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue;

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue;

+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;
+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue;

+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue;
+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue;

- (void)logSetLevel:(LogLevel)level;
- (void)logEnableDomain:(NSString*)domain;
- (void)logEnableDomain:(NSString*)domain forLevel:(LogLevel)level;
- (void)logDisableDomain:(NSString*)domain;
- (void)logDisableDomain:(NSString*)domain forLevel:(LogLevel)level;

@end

CGFloat DNTimeBlock (void (^block)(void));

void DNLogMessageF(const char *filename, int lineNumber, const char *functionName, NSString *domain, int level, NSString *format, ...);
