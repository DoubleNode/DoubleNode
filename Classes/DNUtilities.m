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

#import "DNDate.h"

#import "NSString+HTML.h"
#import "NSDate+Utils.h"

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

+ (NSDateFormatter*)dictionaryDateDateFormatter
{
    static dispatch_once_t  once;
    static NSDateFormatter* instance = nil;

    dispatch_once(&once, ^{
        instance = [[NSDateFormatter alloc] init];
        [instance setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });

    return instance;
}

+ (NSNumberFormatter*)dictionaryDateNumberFormatter
{
    static dispatch_once_t      once;
    static NSNumberFormatter*   instance = nil;

    dispatch_once(&once, ^{
        instance = [[NSNumberFormatter alloc] init];
        [instance setAllowsFloats:NO];
    });

    return instance;
}

+ (CGSize)screenSizeUnits
{
    return (CGSize){ [self screenWidthUnits], [self screenHeightUnits] };
}

+ (CGFloat)screenHeightUnits
{
    CGRect  bounds  = [[UIScreen mainScreen] bounds];
    CGFloat height  = bounds.size.height;
    
    return height;
}

+ (CGFloat)screenWidthUnits
{
    CGRect  bounds  = [[UIScreen mainScreen] bounds];
    CGFloat width   = bounds.size.width;
    
    return width;
}

+ (CGSize)screenSize
{
    return (CGSize){ [self screenWidth], [self screenHeight] };
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
    NSString*   retval  = nibNameOrNil;
    
    //NSString*   bundlePath      = [[NSBundle mainBundle] pathForResource:[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] ofType:@"lproj"];
    NSString*   bundlePath      = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
    NSBundle*   languageBundle  = [NSBundle bundleWithPath:bundlePath];

    if ([DNUtilities isDeviceIPad])
    {
        NSString*   tempNibName = [NSString stringWithFormat:@"%@~ipad", retval];
        if([languageBundle pathForResource:tempNibName ofType:@"nib"] != nil)
        {
            //file found
            retval = tempNibName;
        }
    }
    else
    {
        NSString*   tempNibName = [NSString stringWithFormat:@"%@~iphone", retval];
        if([languageBundle pathForResource:tempNibName ofType:@"nib"] != nil)
        {
            //file found
            retval = tempNibName;
        }
        
        if ([DNUtilities isTall])
        {
            NSString*   tempNibName = [NSString stringWithFormat:@"%@-568h", retval];
            if([languageBundle pathForResource:tempNibName ofType:@"nib"] != nil)
            {
                //file found
                retval = tempNibName;
            }
            
        }
    }
    
    return retval;
}

+ (void)registerCellNib:(NSString*)nibName
     withCollectionView:(UICollectionView*)collectionView
{
    [self registerCellNib:nibName withCollectionView:collectionView withSizingCell:NO];
}

+ (UICollectionViewCell*)registerCellNib:(NSString*)nibName
                      withCollectionView:(UICollectionView*)collectionView
                          withSizingCell:(BOOL)sizingCellFlag
{
    NSString*   cellNibName = [self appendNibSuffix:nibName];
    UINib*      cellNib     = [UINib nibWithNibName:cellNibName bundle:nil];
    [collectionView registerNib:cellNib forCellWithReuseIdentifier:nibName];
    
    UICollectionViewCell*   retval  = nil;
    
    if (sizingCellFlag)
    {
        retval = [cellNib instantiateWithOwner:nil options:nil].firstObject;
    }
    
    return retval;
}

+ (void)registerCellNib:(NSString*)nibName
forSupplementaryViewOfKind:(NSString*)kind
     withCollectionView:(UICollectionView*)collectionView
{
    [self registerCellNib:nibName forSupplementaryViewOfKind:kind withCollectionView:collectionView withSizingCell:NO];
}

+ (UICollectionViewCell*)registerCellNib:(NSString*)nibName
              forSupplementaryViewOfKind:(NSString*)kind
                      withCollectionView:(UICollectionView*)collectionView
                          withSizingCell:(BOOL)sizingCellFlag
{
    NSString*   cellNibName = [self appendNibSuffix:nibName];
    UINib*      cellNib     = [UINib nibWithNibName:cellNibName bundle:nil];
    [collectionView registerNib:cellNib
     forSupplementaryViewOfKind:kind
            withReuseIdentifier:nibName];

    UICollectionViewCell*   retval  = nil;
    
    if (sizingCellFlag)
    {
        retval = [cellNib instantiateWithOwner:nil options:nil].firstObject;
    }
    
    return retval;
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
        case UIInterfaceOrientationUnknown:
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

+ (void)runOnBackgroundThreadAfterDelay:(CGFloat)delay
                                  block:(void (^)())block
{
    [NSThread detachNewThreadSelector:@selector(runAfterDelayBlock:)
                             toTarget:self
                           withObject:@[ [NSNumber numberWithFloat:delay], block ]];
}

+ (void)runAfterDelayBlock:(NSArray*)arrayBlock
{
    CGFloat delay = 0;

    id  delayD = arrayBlock[0];
    if (delayD && [delayD isKindOfClass:[NSNumber class]])
    {
        delay = [delayD floatValue];
    }

    [NSThread sleepForTimeInterval:delay];

    [DNUtilities runBlock:arrayBlock[1]];
}

+ (void)runOnBackgroundThread:(void (^)())block
{
    [NSThread detachNewThreadSelector:@selector(runBlock:)
                             toTarget:self
                           withObject:block];
}

+ (void)runBlock:(void (^)())block
{
    block();
}

+ (void)runOnMainThreadAsynchronouslyWithoutDeadlocking:(void (^)())block
{
    if ([NSThread isMainThread])
    {
        [DNUtilities runOnMainThreadAfterDelay:0.01f
                                         block:
         ^()
         {
             block();
         }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
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

+ (void)runOnMainThreadBlock:(void (^)())block
{
    [DNUtilities runOnMainThreadWithoutDeadlocking:^
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

- (void)instanceRunBlock:(NSTimer*)timer
{
    void (^block)() = timer.userInfo;
    
    block();
}

+ (NSTimer*)repeatRunAfterDelay:(CGFloat)delay block:(void (^)())block
{
    void (^block_)() = [block copy];

    return [NSTimer scheduledTimerWithTimeInterval:delay target:[DNUtilities sharedInstance] selector:@selector(instanceRunBlock:) userInfo:block_ repeats:YES];
}

+ (NSTimer*)runTimerAfterDelay:(CGFloat)delay block:(void (^)())block
{
    void (^block_)() = [block copy];
    
    return [NSTimer scheduledTimerWithTimeInterval:delay target:[DNUtilities sharedInstance] selector:@selector(instanceRunBlock:) userInfo:block_ repeats:NO];
}

+ (void)runGroupOnBackgroundThread:(void (^)(dispatch_group_t group))block
                    withCompletion:(void (^)())completionBlock
{
    [self runGroupWithTimeout:DISPATCH_TIME_FOREVER
           onBackgroundThread:block
               withCompletion:completionBlock];
}

+ (void)runGroupWithTimeout:(dispatch_time_t)timeout
         onBackgroundThread:(void (^)(dispatch_group_t group))block
             withCompletion:(void (^)())completionBlock
{
    [DNUtilities runOnBackgroundThread:
     ^()
     {
         dispatch_group_t group = dispatch_group_create();

         block ? block(group) : nil;
         
         dispatch_group_wait(group, timeout);
         
         completionBlock ? completionBlock() : nil;
     }];
}

+ (void)enterGroup:(dispatch_group_t)group
{
    dispatch_group_enter(group);
}

+ (void)leaveGroup:(dispatch_group_t)group
{
    dispatch_group_leave(group);
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
         //NSError*    error;
         [[AVAudioSession sharedInstance] setActive:NO withFlags:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:NULL];
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
                NSString*   name    = @(temp_addr->ifa_name);
                NSString*   addr    = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
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
    NSString*   addr = wifiAddress ?: cellAddress;
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

    id  object = dictionary[key];
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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

    id  object = dictionary[key];
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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
            NSNumber*   newval  = @([object doubleValue]);

            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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

    id  object = dictionary[key];
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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
    if ((id)retval == (id)@0)
    {
        retval = nil;
    }

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
                NSDate*   newval  = [[[self class] dictionaryDateDateFormatter] dateFromString:object];
                if (newval == nil)
                {
                    NSNumber*   timestamp = [[[self class] dictionaryDateNumberFormatter] numberFromString:object];
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
    }

    return retval;
}

+ (DNDate*)dictionaryDNDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    return [[self class] dictionaryDNDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (DNDate*)dictionaryDNDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    unsigned    dateFlags   = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    DNDate*     retval      = defaultValue;
    if ((id)retval == (id)@0)
    {
        retval = nil;
    }
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if ([object isKindOfClass:[NSNumber class]])
        {
            if (object != (NSNumber*)[NSNull null])
            {
                NSDate*     gmtTime     = [NSDate dateWithTimeIntervalSince1970:[object intValue]];
                NSDate*     localTime   = [gmtTime toGlobalTime];
                
                DNDate*   newval = [DNDate dateWithComponentFlags:dateFlags fromDate:localTime];
                
                if ((retval == nil) || ([newval isEqualToDNDate:retval] == NO))
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
                NSDate*     gmtTime     = [NSDate dateWithTimeIntervalSince1970:[object intValue]];
                NSDate*     localTime   = [gmtTime toGlobalTime];
                
                DNDate*   newval = [DNDate dateWithComponentFlags:dateFlags fromDate:localTime];
                if (newval == nil)
                {
                    NSNumber*   timestamp = [[[self class] dictionaryDateNumberFormatter] numberFromString:object];
                    if (timestamp != nil)
                    {
                        if ([timestamp integerValue] != 0)
                        {
                            NSDate*     gmtTime     = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
                            NSDate*     localTime   = [gmtTime toGlobalTime];
                            
                            newval = [DNDate dateWithComponentFlags:dateFlags fromDate:localTime];
                        }
                    }
                }
                if (newval)
                {
                    if ((retval == nil) || ([newval isEqualToDNDate:retval] == NO))
                    {
                        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                        retval = newval;
                    }
                }
            }
        }
        else if ([object isKindOfClass:[DNDate class]])
        {
            if (object != (DNDate*)[NSNull null])
            {
                DNDate*   newval  = object;
                
                if ((retval == nil) || ([newval isEqualToDNDate:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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

    if (dictionary[key] != nil)
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
    else if (retval)
    {
        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
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
        logDebugDomains[domain] = @(level);
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
        logDebugDomains[domain] = @(level - 1);
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
        NSLog(@"[%@] {%@} [%@:%d] %@", ([NSThread isMainThread] ? @"MT" : @"BT"), domain, [[NSString stringWithUTF8String:filename] lastPathComponent], lineNumber, formattedStr);
        
        va_end(args);
    }
}

