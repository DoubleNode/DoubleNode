//
//  DNThemeManager.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DNUtilities.h"

#import "ADVTheme.h"

@class DNTextView, DNTextField, DNLabel, DNSegmentedControl;

@protocol DNThemeProtocol <ADVTheme, NSObject>

- (UIColor*)primaryColor;
- (UIColor*)secondaryColor;

- (void)resetCache;

- (SEL)functionNameForAttribute:(NSString*)attribute
                       withType:(NSString*)type
                       andGroup:(NSString*)group
                      andScreen:(NSString*)screen
                   andViewState:(NSString*)viewState
                        andItem:(NSString*)item
                andControlState:(NSString*)controlStateString;

@end

@interface DNThemeManager : ADVThemeManager

+ (NSString*)themeName;
+ (id <DNThemeProtocol>)sharedTheme;

+ (UIColor*)primaryColor;
+ (UIColor*)secondaryColor;

+ (void)resetCache;

+ (NSString*)customizeNibNameWithClass:(NSString*)className
                             withGroup:(NSString*)group
                             andScreen:(NSString*)screen;

+ (void)customizeView:(UIView*)view
            withGroup:(NSString*)group
            andScreen:(NSString*)screen
              andItem:(NSString*)item;

+ (void)customizeView:(UIView*)view
            withGroup:(NSString*)group
            andScreen:(NSString*)screen
         andViewState:(NSString*)viewState
              andItem:(NSString*)item;

+ (void)customizeLabel:(UILabel*)lblView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
               andItem:(NSString*)item;

+ (void)customizeLabel:(UILabel*)lblView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
          andViewState:(NSString*)viewState
               andItem:(NSString*)item;

+ (void)customizeImage:(UIImageView*)imgView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
               andItem:(NSString*)item;

+ (void)customizeImage:(UIImageView*)imgView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
          andViewState:(NSString*)viewState
               andItem:(NSString*)item;

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
                andItem:(NSString*)item;

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
           andViewState:(NSString*)viewState
                andItem:(NSString*)item;

+ (void)customizeTextField:(UITextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
                   andItem:(NSString*)item;

+ (void)customizeTextField:(UITextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
              andViewState:(NSString*)viewState
                   andItem:(NSString*)item;

+ (void)customizeTextView:(UITextView*)txtView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
                  andItem:(NSString*)item;

+ (void)customizeTextView:(UITextView*)txtView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
             andViewState:(NSString*)viewState
                  andItem:(NSString*)item;

+ (void)customizeSegmentedControl:(UISegmentedControl*)segmentedControl
                        withGroup:(NSString*)group
                        andScreen:(NSString*)screen
                          andItem:(NSString*)item;

+ (void)customizeSegmentedControl:(UISegmentedControl*)segmentedControl
                        withGroup:(NSString*)group
                        andScreen:(NSString*)screen
                     andViewState:(NSString*)viewState
                          andItem:(NSString*)item;

+ (void)customizeBarButtonItem:(UIBarButtonItem*)barButtonItem
                     withGroup:(NSString*)group
                     andScreen:(NSString*)screen
                       andItem:(NSString*)item;

+ (void)customizeBarButtonItem:(UIBarButtonItem*)barButtonItem
                     withGroup:(NSString*)group
                     andScreen:(NSString*)screen
                  andViewState:(NSString*)viewState
                       andItem:(NSString*)item;

+ (void)customizeSwitch:(UISwitch*)switchView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
                  andItem:(NSString*)item;

+ (void)customizeSwitch:(UISwitch*)switchView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
             andViewState:(NSString*)viewState
                  andItem:(NSString*)item;

@end
