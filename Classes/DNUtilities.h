//
//  DNUtilities.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/12/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "Stats.h"
//#import "DCIntrospect.h"

//#import "RIButtonItem.h"
//#import "UIAlertView+Blocks.h"
//#import "UIActionSheet+Blocks.h"

//#import "DNAppConstants.h"
//#import "DNEventInterceptWindow.h"

//#import "GANTracker.h"
#import "LoggerClient.h"
//#import "SIAlertView.h"

//#import "UIView+FrameAccessor.h"
//#import "UIColor+HexString.h"
//#import "NSDate+PrettyDate.h"
//#import "UIFont+Custom.h"

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef enum
{
    LL_Critical = 0,
    LL_Error,
    LL_Warning,
    LL_Debug,
    LL_Info,
    LL_Everything
}
LogLevel;

#if defined(CONFIGURATION_Live)
    #define DLog(...)       do{}while(0)
    #define DLogImage(...)  do{}while(0)
#else
    #define DLog(level, ...)        LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"general",level,__VA_ARGS__)
    #define DLogImage(level, image) LogImageDataF(__FILE__,__LINE__,__FUNCTION__,@"general",level,image.size.width,image.size.height,UIImagePNGRepresentation(image))

extern void LogImageDataF(const char *filename, int lineNumber, const char *functionName, NSString *domain, int level, int width, int height, NSData *data);

    #undef assert
    #if __DARWIN_UNIX03
        #define assert(e)   (__builtin_expect(!(e), 0) ? (CFShow(CFSTR("assert going to fail, connect NSLogger NOW\n")), LoggerFlush(NULL,YES), __assert_rtn(__func__, __FILE__, __LINE__, #e)) : (void)0)
    #else
        #define assert(e)   (__builtin_expect(!(e), 0) ? (CFShow(CFSTR("assert going to fail, connect NSLogger NOW\n")), LoggerFlush(NULL,YES), __assert(#e, __FILE__, __LINE__)) : (void)0)
    #endif
#endif

typedef void (^RevealBlock)(BOOL left);
typedef BOOL (^RevealBlock_Bool)(BOOL left);

@interface DNUtilities : NSObject

+ (CGFloat)screenHeight;
+ (BOOL)isTall;
+ (BOOL)isDeviceIPad;

+ (NSString*)appendNibSuffix:(NSString*)nibNameOrNil;
+ (NSString*)deviceImageName:(NSString*)name;

+ (void)runBlock:(void (^)())block;
+ (void)runAfterDelay:(CGFloat)delay block:(void (^)())block;
+ (NSTimer*)repeatRunAfterDelay:(CGFloat)delay block:(void (^)())block;
+ (bool)canDevicePlaceAPhoneCall;

+ (void)playSound:(NSString*)name;
+ (NSString*)encodeWithHMAC_SHA1:(NSString*)data withKey:(NSString*)key;

+ (void)setEventInterceptDelegate:(id<DNEventInterceptWindowDelegate>)delegate;

+ (UIImage*)imageScaledForRetina:(UIImage*)image;

+ (id)settingsItem:(NSString*)item;
+ (id)settingsItem:(NSString*)item default:(id)defaultValue;
+ (id)settingsItem:(NSString*)item boolDefault:(BOOL)defaultValue;
+ (void)setSettingsItem:(NSString*)item value:(id)value;
+ (void)setSettingsItem:(NSString*)item boolValue:(BOOL)value;

+ (NSString *)getIPAddress;

+ (void)updateImage:(UIImageView*)imageView
           newImage:(UIImage*)newImage;

@end
