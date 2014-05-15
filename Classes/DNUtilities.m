//
//  DNUtilities.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#define DEBUGLOGGING
#import "DNUtilities.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#include <CommonCrypto/CommonHMAC.h>
#import <mach/mach_time.h> // for mach_absolute_time() and friends

#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#import "NSString+HTML.h"

@interface DNUtilities()
{
    LogLevel                logDebugLevel;
    NSMutableDictionary*    logDebugDomains;
}
@end

@implementation DNUtilities

+ (id<DNApplicationProtocol>)appDelegate
{
    return (id<DNApplicationProtocol>)[[UIApplication sharedApplication] delegate];
}

+ (DNUtilities*)sharedInstance
{
    static dispatch_once_t  once;
    static DNUtilities*     instance = nil;
    
    dispatch_once(&once, ^{
        instance = [[DNUtilities alloc] init];
    });
    
    return instance;
}

+ (CGFloat)screenHeight
{
    CGRect  bounds  = [[UIScreen mainScreen] bounds];
    CGFloat height  = bounds.size.height;
    CGFloat scale   = [[UIScreen mainScreen] scale];
    
    return (height * scale);
}

+ (CGFloat)screenWidth
{
    CGRect  bounds  = [[UIScreen mainScreen] bounds];
    CGFloat width   = bounds.size.width;
    CGFloat scale   = [[UIScreen mainScreen] scale];

    return (width * scale);
}

+ (BOOL)isTall
{
    static dispatch_once_t  once;
    static BOOL             result = NO;
    
    dispatch_once(&once, ^{
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat height = bounds.size.height;
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        result = (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && ((height * scale) >= 1136));
    });
    
    return result;
}

+ (BOOL)isDeviceIPad
{
    static dispatch_once_t  once;
    static BOOL             result = NO;
    
    dispatch_once(&once, ^{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            result = YES;
        }
    });
    
    return result;
}

+ (NSString*)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString*)appendNibSuffix:(NSString*)nibNameOrNil withDefaultNib:(NSString*)defaultNib
{
    if ([nibNameOrNil length] == 0)
    {
        nibNameOrNil    = defaultNib;
    }

    return [DNUtilities appendNibSuffix:nibNameOrNil];
}

+ (NSString*)appendNibSuffix:(NSString*)nibNameOrNil
{
    //NSString*   bundlePath      = [[NSBundle mainBundle] pathForResource:[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] ofType:@"lproj"];
    NSString*   bundlePath      = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
    NSBundle*   languageBundle  = [NSBundle bundleWithPath:bundlePath];

    if ([DNUtilities isDeviceIPad])
    {
        NSString*   tempNibName = [NSString stringWithFormat:@"%@~ipad", nibNameOrNil];
        if([languageBundle pathForResource:tempNibName ofType:@"nib"] != nil)
        {
            //file found
            nibNameOrNil = tempNibName;
        }
    }
    else
    {
        NSString*   tempNibName = [NSString stringWithFormat:@"%@~iphone", nibNameOrNil];
        if([languageBundle pathForResource:tempNibName ofType:@"nib"] != nil)
        {
            //file found
            nibNameOrNil = tempNibName;
        }
        
        if ([DNUtilities isTall])
        {
            NSString*   tempNibName = [NSString stringWithFormat:@"%@-568h", nibNameOrNil];
            if([languageBundle pathForResource:tempNibName ofType:@"nib"] != nil)
            {
                //file found
                nibNameOrNil = tempNibName;
            }
            
        }
    }
    
    return nibNameOrNil;
}

+ (NSString*)deviceImageName:(NSString*)name
{
    NSString*   fileName        = [[[NSFileManager defaultManager] displayNameAtPath:name] stringByDeletingPathExtension];
    NSString*   extension       = [name pathExtension];
    
    NSString*   orientationStr  = @"";
    NSString*   orientation2Str = @"";
    NSString*   deviceStr       = @"";
    
    UIInterfaceOrientation  orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        {
            orientationStr  = @"-Portrait";
            orientation2Str = @"-Portrait";
            break;
        }

        case UIInterfaceOrientationPortraitUpsideDown:
        {
            orientationStr  = @"-Portrait";
            orientation2Str = @"-PortraitUpsideDown";
            break;
        }
            
        case UIInterfaceOrientationLandscapeLeft:
        {
            orientationStr  = @"-Landscape";
            orientation2Str = @"-LandscapeLeft";
            break;
        }
            
        case UIInterfaceOrientationLandscapeRight:
        {
            orientationStr  = @"-Landscape";
            orientation2Str = @"-LandscapeRight";
            break;
        }
    }

    if ([DNUtilities isDeviceIPad])
    {
        deviceStr   = @"~ipad";
    }
    else
    {
        if ([DNUtilities isTall])
        {
            deviceStr   = @"-568h@2x";
        }
        else
        {
            deviceStr   = @"~iphone";
        }
    }

    NSString*   tempName;
    
    tempName = [fileName stringByAppendingFormat:@"%@%@", deviceStr, orientation2Str];
    if ([[NSBundle mainBundle] pathForResource:tempName ofType:extension] != nil)
    {
        return [tempName stringByAppendingFormat:@".%@", extension];
    }
    
    tempName = [fileName stringByAppendingFormat:@"%@", orientation2Str];
    if ([[NSBundle mainBundle] pathForResource:tempName ofType:extension] != nil)
    {
        return [tempName stringByAppendingFormat:@".%@", extension];
    }
    
    tempName = [fileName stringByAppendingFormat:@"%@%@", deviceStr, orientationStr];
    if ([[NSBundle mainBundle] pathForResource:tempName ofType:extension] != nil)
    {
        return [tempName stringByAppendingFormat:@".%@", extension];
    }
    
    tempName = [fileName stringByAppendingFormat:@"%@", orientationStr];
    if ([[NSBundle mainBundle] pathForResource:tempName ofType:extension] != nil)
    {
        return [tempName stringByAppendingFormat:@".%@", extension];
    }
    
    tempName = [fileName stringByAppendingFormat:@"%@", deviceStr];
    if ([[NSBundle mainBundle] pathForResource:tempName ofType:extension] != nil)
    {
        return [tempName stringByAppendingFormat:@".%@", extension];
    }
    
    return [fileName stringByAppendingFormat:@".%@", extension];
}

+ (void)runOnMainThreadWithoutDeadlocking:(void (^)())block
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (void)runOnBackgroundThread:(void (^)())block
{
    [NSThread detachNewThreadSelector:@selector(runBlock:)
                             toTarget:self
                           withObject:block];
}

+ (void)runBlock:(void (^)())block
{
    [DNUtilities runOnMainThreadWithoutDeadlocking:^
     {
         block();
     }];
}

+ (void)runOnMainThreadBlock:(void (^)())block
{
    [DNUtilities runOnBackgroundThread:^
     {
         block();
     }];
}

+ (void)runAfterDelay:(CGFloat)delay block:(void (^)())block
{
    void (^block_)() = [block copy];
    [self performSelector:@selector(runBlock:) withObject:block_ afterDelay:delay];
}

+ (void)runOnMainThreadAfterDelay:(CGFloat)delay block:(void (^)())block
{
    void (^block_)() = [block copy];
    [self performSelector:@selector(runOnMainThreadBlock:) withObject:block_ afterDelay:delay];
}

+ (void)runRepeatedlyAfterDelay:(CGFloat)delay block:(void (^)(BOOL* stop))block
{
    [[self class] runAfterDelay:delay
                          block:^
     {
         BOOL   stop = NO;
         block(&stop);
         if (stop == NO)
         {
             [[self class] runRepeatedlyAfterDelay:delay
                                             block:block];
         }
     }];
}

+ (void)runOnMainThreadRepeatedlyAfterDelay:(CGFloat)delay block:(void (^)(BOOL* stop))block
{
    [[self class] runOnMainThreadAfterDelay:delay
                                      block:^
     {
         BOOL   stop = NO;
         block(&stop);
         if (stop == NO)
         {
             [[self class] runOnMainThreadRepeatedlyAfterDelay:delay
                                                         block:block];
         }
     }];
}

- (void)instanceRunBlock:(void (^)())block
{
    block();
    //[DNUtilities runBlock:block];
}

+ (NSTimer*)repeatRunAfterDelay:(CGFloat)delay block:(void (^)())block
{
    void (^block_)() = [block copy];

    return [NSTimer scheduledTimerWithTimeInterval:delay target:[DNUtilities sharedInstance] selector:@selector(instanceRunBlock:) userInfo:block_ repeats:YES];
}

+ (bool)canDevicePlaceAPhoneCall
{
    /*
        Returns YES if the device can place a phone call
     */
    
    // Check if the device can place a phone call
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
    {
        // Device supports phone calls, lets confirm it can place one right now
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        NSString *mnc = [carrier mobileNetworkCode];
        
        if (([mnc length] > 0) && (![mnc isEqualToString:@"65535"]))
        {
            // Device can place a phone call
            return YES;
        }
    }

    // Device does not support phone calls
    return  NO;
}

+(AVAudioPlayer*)createSound:(NSString*)fName ofType:(NSString*)ext
{
    AVAudioPlayer*  avSound = nil;
    
    NSString*   path  = [[NSBundle mainBundle] pathForResource:fName ofType:ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSURL*  pathURL = [NSURL fileURLWithPath:path];
        
        @try
        {
            avSound = [[AVAudioPlayer alloc] initWithContentsOfURL:pathURL error:nil];
        }
        @catch (NSException *exception)
        {
        }

        [avSound prepareToPlay];
    }
    else
    {
        DLog(LL_Debug, LD_General, @"error, file not found: %@", path);
    }
    
    return avSound;
}

+ (void)playSound:(NSString*)name
{
    static AVAudioPlayer*  avSound_buzz = nil;
    static AVAudioPlayer*  avSound_ding = nil;
    static AVAudioPlayer*  avSound_tada = nil;
    static AVAudioPlayer*  avSound_beep = nil;
    
    static dispatch_once_t  once;
    
    dispatch_once(&once, ^{
        avSound_buzz    = [DNUtilities createSound:@"buzz_Error" ofType:@"mp3"];
        avSound_ding    = [DNUtilities createSound:@"ding_Capture" ofType:@"mp3"];
        avSound_tada    = [DNUtilities createSound:@"tada_Reward" ofType:@"mp3"];
        avSound_beep    = [DNUtilities createSound:@"beep_Scanner" ofType:@"mp3"];
    });

    if ([name isEqualToString:@"buzz"] == YES)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [avSound_buzz play];
    }
    else if ([name isEqualToString:@"ding"] == YES)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [avSound_ding play];
    }
    else if ([name isEqualToString:@"tada"] == YES)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [avSound_tada play];
    }
    else if ([name isEqualToString:@"beep"] == YES)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [avSound_beep play];
    }
    
    [DNUtilities runAfterDelay:3.0f block:^
     {
         NSError*    error;
         [[AVAudioSession sharedInstance] setActive:NO withFlags:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
     }];
}

+ (NSString*)encodeWithHMAC_SHA1:(NSString*)data withKey:(NSString*)key
{
    const char* cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];    // NSASCIIStringEncoding];
    const char* cData = [data cStringUsingEncoding:NSUTF8StringEncoding];   // NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString*   hexStr = [NSString  stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        cHMAC[0], cHMAC[1], cHMAC[2], cHMAC[3], cHMAC[4],
                        cHMAC[5], cHMAC[6], cHMAC[7],
                        cHMAC[8], cHMAC[9], cHMAC[10], cHMAC[11], cHMAC[12],
                        cHMAC[13], cHMAC[14], cHMAC[15],
                        cHMAC[16], cHMAC[17], cHMAC[18], cHMAC[19]
                     ];
    
    return hexStr;
}

+ (UIImage*)imageScaledForRetina:(UIImage*)image
{
    // [UIImage imageWithCGImage:[newImage CGImage] scale:2.0 orientation:UIImageOrientationUp];
    // [newImage scaleProportionalToSize:CGSizeMake(32, 32)];

    double  scale   = [[UIScreen mainScreen] scale];
    //NSLog(@"scale=%.2f", scale);
    
    return [UIImage imageWithCGImage:[image CGImage] scale:scale orientation:UIImageOrientationUp];
}

+ (id)settingsItem:(NSString*)item
{
    return [[[self class] appDelegate] settingsItem:item];
}

+ (id)settingsItem:(NSString*)item default:(id)defaultValue
{
    return [[[self class] appDelegate] settingsItem:item default:defaultValue];
}

+ (BOOL)settingsItem:(NSString*)item boolDefault:(BOOL)defaultValue
{
    return [[[self class] appDelegate] settingsItem:item boolDefault:defaultValue];
}

+ (void)setSettingsItem:(NSString*)item value:(id)value
{
    [[[self class] appDelegate] setSettingsItem:item value:value];
}

+ (void)setSettingsItem:(NSString*)item boolValue:(BOOL)value
{
    [[[self class] appDelegate] setSettingsItem:item boolValue:value];
}

+ (NSString *)getIPAddress
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                //NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}

+ (void)updateImage:(UIImageView*)imageView
           newImage:(UIImage*)newImage
{
    [UIView animateWithDuration:0.2f
                     animations:^
     {
         imageView.alpha = 0.0f;
     }
                     completion:^(BOOL finished)
     {
         imageView.image = newImage;
         
         [UIView animateWithDuration:0.2f
                          animations:^
          {
              imageView.alpha = 1.0f;
          }];
     }];
}

#pragma mark - Dictionary Translation functions

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryBoolean:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSNumber*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithInt:[object boolValue]];

            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }

    return retval;
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSNumber*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithInt:[object intValue]];

            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }

    return retval;
}

+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    return [[self class] dictionaryDecimalNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    NSDecimalNumber*   retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSDecimalNumber*)[NSNull null])
        {
            NSDecimalNumber*   newval  = [NSDecimalNumber decimalNumberWithDecimal:[object decimalValue]];

            if ((retval == nil) || ([newval compare:retval] != NSOrderedSame))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }

    return retval;
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryDouble:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSString*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithDouble:[object doubleValue]];

            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }

    return retval;
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [[self class] dictionaryString:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    NSString*   retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if ([object isKindOfClass:[NSArray class]] == YES)
        {
            if (object != (NSArray*)[NSNull null])
            {
                if ([object count] > 0)
                {
                    NSString*   newval  = object[0];

                    if ((retval == nil) || ([newval isEqualToString:retval] == NO))
                    {
                        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                        retval = newval;
                    }
                }
            }
        }
        else
        {
            if ([object isKindOfClass:[NSString class]] == YES)
            {
                if ([object isEqualToString:@"<null>"] == YES)
                {
                    object  = @"";
                }
            }
            else if ([object isKindOfClass:[NSNull class]] == YES)
            {
                object = @"";
            }
            else
            {
                object = [object stringValue];
            }
            if (object != (NSString*)[NSNull null])
            {
                NSString*   newval  = object;

                if ((retval == nil) || ([newval isEqualToString:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }

    return [retval stringByDecodingXMLEntities];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [[self class] dictionaryArray:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    NSArray*    retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSArray*)[NSNull null])
        {
            if ([object isKindOfClass:[NSArray class]] == YES)
            {
                NSArray*   newval  = object;

                if ((retval == nil) || ([newval isEqualToArray:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }

    return retval;
}

+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    return [[self class] dictionaryDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    NSDictionary*    retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSDictionary*)[NSNull null])
        {
            if ([object isKindOfClass:[NSDictionary class]] == YES)
            {
                NSDictionary*   newval  = object;

                if ((retval == nil) || ([newval isEqualToDictionary:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }

    return retval;
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [[self class] dictionaryDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    NSDate*   retval  = defaultValue;

    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if ([object isKindOfClass:[NSNumber class]])
        {
            if (object != (NSNumber*)[NSNull null])
            {
                NSDate*   newval  = [NSDate dateWithTimeIntervalSince1970:[object intValue]];

                if ((retval == nil) || ([newval isEqualToDate:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
        else if ([object isKindOfClass:[NSString class]])
        {
            if (object != (NSString*)[NSNull null])
            {
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

                NSDate*   newval  = [dateFormatter dateFromString:object];
                if (newval == nil)
                {
                    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setAllowsFloats:NO];

                    NSNumber*   timestamp = [numberFormatter numberFromString:object];
                    if (timestamp != nil)
                    {
                        if ([timestamp integerValue] != 0)
                        {
                            newval = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
                        }
                    }
                }
                if (newval)
                {
                    if ((retval == nil) || ([newval isEqualToDate:retval] == NO))
                    {
                        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                        retval = newval;
                    }
                }
            }
        }
        else if ([object isKindOfClass:[NSDate class]])
        {
            if (object != (NSDate*)[NSNull null])
            {
                NSDate*   newval  = object;

                if ((retval == nil) || ([newval isEqualToDate:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }

    return retval;
}

+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [[self class] dictionaryObject:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue
{
    id  retval  = defaultValue;

    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (id)[NSNull null])
        {
            id  newval  = dictionary[key];

            if ((retval == nil) || ([newval isEqual:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        logDebugLevel   = LL_Everything;
        logDebugDomains = [NSMutableDictionary dictionary];

        [DNUtilities runOnBackgroundThread:^
         {
             [self logResetLogState];
         }];
    }

    return self;
}

- (void)logResetLogState
{
    if ([[[self class] appDelegate] respondsToSelector:@selector(resetLogState)] == YES)
    {
        [[[self class] appDelegate] resetLogState];
    };
}

- (void)logSetLevel:(LogLevel)level
{
    logDebugLevel   = level;
}

- (void)logEnableDomain:(NSString*)domain
{
    [self logEnableDomain:domain forLevel:LL_Everything];
}

- (void)logEnableDomain:(NSString*)domain forLevel:(LogLevel)level
{
    @synchronized(logDebugDomains)
    {
        [logDebugDomains setObject:[NSNumber numberWithInt:level] forKey:domain];
    }
}

- (void)logDisableDomain:(NSString*)domain
{
    [self logDisableDomain:domain forLevel:LL_Everything];
}

- (void)logDisableDomain:(NSString*)domain forLevel:(LogLevel)level
{
    @synchronized(logDebugDomains)
    {
        [logDebugDomains setObject:[NSNumber numberWithInt:(level - 1)] forKey:domain];
    }
}

- (BOOL)isLogEnabledDomain:(NSString*)domain
                  andLevel:(int)level
{
    if (level > logDebugLevel)
    {
        return NO;
    }

    __block BOOL    retval = YES;

    @synchronized(logDebugDomains)
    {
        [logDebugDomains enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber* obj, BOOL* stop)
         {
             if ([key isEqualToString:domain])
             {
                 retval = (level <= [[logDebugDomains objectForKey:domain] intValue]);
                 *stop = YES;
             }
         }];
    }

    return retval;
}

@end

//
// Function provided by BigNerdRanch
// https://gist.github.com/bignerdranch/2006587
//
CGFloat DNTimeBlock (void (^block)(void))
{
    mach_timebase_info_data_t   info;
    if (mach_timebase_info(&info) != KERN_SUCCESS)
    {
        return -1.0;
    }

    uint64_t    start   = mach_absolute_time ();
    block ();
    uint64_t    end     = mach_absolute_time ();
    uint64_t    elapsed = end - start;

    uint64_t    nanos   = (elapsed * info.numer) / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
}

void DNLogMessageF(const char *filename, int lineNumber, const char *functionName, NSString *domain, int level, NSString *format, ...)
{
    if ([[DNUtilities sharedInstance] isLogEnabledDomain:domain andLevel:level] == YES)
    {
        va_list args;
        va_start(args, format);

        NSString*   formattedStr = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"{%@} [%@:%d] %@", domain, [[NSString stringWithUTF8String:filename] lastPathComponent], lineNumber, formattedStr);
        
        va_end(args);
    }
}

