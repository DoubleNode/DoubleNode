//
//  DNAppDelegate.h
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 10/30/13.
//  Copyright (c) 2013 DoubleNode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "DNApplicationProtocol.h"

@interface DNAppDelegate : UIResponder <UIApplicationDelegate, DNApplicationProtocol>
{
    NSString*   persistentStorePrefix;
    BOOL        doNotUseIncrementalStore;
    
    NSMutableDictionary*    managedObjectModelDictionary;
    NSMutableDictionary*    managedObjectContextDictionary;
    NSMutableDictionary*    persistentStoreDictionary;
    NSMutableDictionary*    persistentStoreCoordinatorDictionary;
}

@property (strong, nonatomic) UIWindow *window;

@end
