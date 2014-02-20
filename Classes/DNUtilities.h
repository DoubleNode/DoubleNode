//
//  DNUtilities.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/12/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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

#if !defined(DEBUG)
    #define DLogMarker(marker)          NSLog(@"%@", marker)
    #define DLog(level,domain,...)      NSLog(__VA_ARGS__)
    #define DLogData(level,domain,data) do{}while(0)
    #define DLogImage(...)              do{}while(0)
#else
    #define DLogMarker(marker)              NSLog(@"%@", marker); LogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,@"%@", marker)
    #define DLog(level,domain,...)          DNLogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,__VA_ARGS__); LogMessageF(__FILE__,__LINE__,__FUNCTION__,domain,level,__VA_ARGS__)
    #define DLogData(level,domain,data)     LogDataF(__FILE__,__LINE__,__FUNCTION__,domain,level,data)
    #define DLogImage(level,domain,image)   LogImageDataF(__FILE__,__LINE__,__FUNCTION__,domain,level,image.size.width,image.size.height,UIImagePNGRepresentation(image))

extern void LogImageDataF(const char *filename, int lineNumber, const char *functionName, NSString *domain, int level, int width, int height, NSData *data);

    #undef assert
    #if __DARWIN_UNIX03
        #define assert(e)   (__builtin_expect(!(e), 0) ? (CFShow(CFSTR("assert going to fail, connect NSLogger NOW\n")), LoggerFlush(NULL,YES), __assert_rtn(__func__, __FILE__, __LINE__, #e)) : (void)0)
    #else
        #define assert(e)   (__builtin_expect(!(e), 0) ? (CFShow(CFSTR("assert going to fail, connect NSLogger NOW\n")), LoggerFlush(NULL,YES), __assert(#e, __FILE__, __LINE__)) : (void)0)
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

+ (void)runOnMainThreadWithoutDeadlocking:(void (^)())block;
+ (void)runBlock:(void (^)())block;
+ (void)runAfterDelay:(CGFloat)delay block:(void (^)())block;
+ (void)runRepeatedlyAfterDelay:(CGFloat)delay block:(void (^)(BOOL* stop))block;
+ (NSTimer*)repeatRunAfterDelay:(CGFloat)delay block:(void (^)())block;
+ (bool)canDevicePlaceAPhoneCall;

+ (void)playSound:(NSString*)name;
+ (NSString*)encodeWithHMAC_SHA1:(NSString*)data withKey:(NSString*)key;

+ (UIImage*)imageScaledForRetina:(UIImage*)image;

+ (id)settingsItem:(NSString*)item;
+ (id)settingsItem:(NSString*)item default:(id)defaultValue;
+ (id)settingsItem:(NSString*)item boolDefault:(BOOL)defaultValue;
+ (void)setSettingsItem:(NSString*)item value:(id)value;
+ (void)setSettingsItem:(NSString*)item boolValue:(BOOL)value;

+ (NSString *)getIPAddress;

+ (void)updateImage:(UIImageView*)imageView
           newImage:(UIImage*)newImage;

- (void)logSetLevel:(int)level;
- (void)logEnableDomain:(NSString*)domain;
- (void)logDisableDomain:(NSString*)domain;

@end

void DNLogMessageF(const char *filename, int lineNumber, const char *functionName, NSString *domain, int level, NSString *format, ...);
