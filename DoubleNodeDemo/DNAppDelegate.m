//
//  DNAppDelegate.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 10/30/13.
//  Copyright (c) 2013 DoubleNode. All rights reserved.
//

#import "DNAppDelegate.h"

#import "DNUtilities.h"

#import "DNSampleCollectionViewController.h"

@implementation DNAppDelegate

#pragma mark - General DNApplicationProtocol functions

- (BOOL)isReachable
{
    return YES;
}

- (NSString*)buildString
{
    return [[NSBundle mainBundle]infoDictionary][(NSString*)kCFBundleVersionKey];
}

- (NSString*)versionString
{
    return [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"];
}

- (NSString*)bundleName
{
    return [[NSBundle mainBundle]infoDictionary][(NSString*)kCFBundleNameKey];
}

- (UIViewController*)rootViewController
{
    return self.window.rootViewController;
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
    [DNUtilities runOnMainThreadWithoutDeadlocking:
     ^()
     {
         static NSInteger   numberOfCallsToSetVisible = 0;
         if (setVisible)
         {
             numberOfCallsToSetVisible++;
         }
         else
         {
             numberOfCallsToSetVisible--;
         }
         //DLog(LL_Debug, LD_Networking, @"visible=%@ numberOfCallsToSetVisible=%ld", ((numberOfCallsToSetVisible > 0) ? @"YES" : @"NO"), (long)numberOfCallsToSetVisible);
         
         // Display the indicator as long as our static counter is > 0.
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(numberOfCallsToSetVisible > 0)];
     }];
}

#pragma mark - CoreData DNApplicationProtocol functions

- (NSString*)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)disableURLCache
{
}

- (void)setDoNotUseIncrementalStore:(BOOL)flagValue
{
    doNotUseIncrementalStore    = flagValue;
    
    DLog(LL_Debug, LD_Framework, @"** %@ INCREMENTAL STORE **", (doNotUseIncrementalStore ? @"DISABLED" : @"ENABLED"));
}

- (void)setPersistentStorePrefix:(NSString*)prefix
{
    persistentStorePrefix    = prefix;
    
    DLog(LL_Debug, LD_Framework, @"** UPDATED PREFIX ** SQLite URL: %@", [[self getPersistentStoreURL:@"Main"] absoluteString]);
}

- (NSURL*)getPersistentStoreURL:(NSString*)filename
{
    return [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: [NSString stringWithFormat:@"%@%@.sqlite", persistentStorePrefix, filename]]];
}

#pragma mark - NSUserDefaults settings items

- (id)settingsItem:(NSString*)item
{
    return [self settingsItem:item default:@""];
}

- (id)settingsItem:(NSString*)item default:(id)defaultValue
{
    __block id  retval;
    
    //[DNUtilities runOnMainThreadWithoutDeadlocking:
    // ^()
    // {
    NSString*   key     = [NSString stringWithFormat:@"Setting_%@", item];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:defaultValue forKey:key];
    }
    
    retval = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    // }];
    
    return retval;
}

- (BOOL)settingsItem:(NSString*)item
         boolDefault:(BOOL)defaultValue
{
    return [[self settingsItem:item default:(defaultValue ? @"1" : @"0")] boolValue];
}

- (void)setSettingsItem:(NSString*)item
                  value:(id)value
{
    //[DNUtilities runOnMainThreadWithoutDeadlocking:
    // ^()
    // {
    NSString*   key     = [NSString stringWithFormat:@"Setting_%@", item];
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // }];
}

- (void)setSettingsItem:(NSString*)item
              boolValue:(BOOL)value;
{
    [self setSettingsItem:item value:(value ? @"1" : @"0")];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    persistentStorePrefix       = @"";
    doNotUseIncrementalStore    = NO;
    
    managedObjectModelDictionary            = [NSMutableDictionary dictionaryWithCapacity:10];
    managedObjectContextDictionary          = [NSMutableDictionary dictionaryWithCapacity:10];
    persistentStoreDictionary               = [NSMutableDictionary dictionaryWithCapacity:10];
    persistentStoreCoordinatorDictionary    = [NSMutableDictionary dictionaryWithCapacity:10];
    
    //[self setDoNotUseIncrementalStore:YES];
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[DNSampleCollectionViewController alloc] initWithNibName:@"DNSampleCollectionViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
