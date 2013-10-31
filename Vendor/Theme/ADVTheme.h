//
//  ADVTheme.h
//  
//
//  Created by Valentin Filip on 7/9/12.
//  Copyright (c) 2013 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, SSThemeTab)
{
    SSThemeTabSecure,
    SSThemeTabDocs,
    SSThemeTabBugs,
    SSThemeTabBook,
    SSThemeTabOptions
};

@protocol ADVTheme <NSObject>

- (UIStatusBarStyle)statusBarStyle;

- (UIColor *)mainColor;
- (UIColor *)secondColor;
- (UIColor *)navigationTextColor;
- (UIColor *)highlightColor;
- (UIColor *)shadowColor;
- (UIColor *)highlightShadowColor;
- (UIColor *)navigationTextShadowColor;
- (UIColor *)backgroundColor;

- (UIFont *)navigationFont;
- (UIFont *)barButtonFont;
- (UIFont *)segmentFont;

- (UIColor *)baseTintColor;
- (UIColor *)accentTintColor;
- (UIColor *)selectedTabbarItemTintColor;

- (UIColor *)switchThumbColor;
- (UIColor *)switchOnColor;
- (UIColor *)switchTintColor;
- (UIColor *)segmentedTintColor;

- (CGSize)shadowOffset;

- (UIImage *)topShadow;
- (UIImage *)bottomShadow;

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics;
- (UIImage *)navigationBackgroundForIPadAndOrientation:(UIInterfaceOrientation)orientation;
- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

- (UIImage *)toolbarBackgroundForBarMetrics:(UIBarMetrics)metrics;

- (UIImage *)searchBackground;
- (UIImage *)searchScopeBackground;
- (UIImage *)searchFieldImage;
- (UIImage *)searchImageForIcon:(UISearchBarIcon)icon state:(UIControlState)state;
- (UIImage *)searchScopeButtonBackgroundForState:(UIControlState)state;
- (UIImage *)searchScopeButtonDivider;

- (UIImage *)segmentedBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)segmentedDividerForBarMetrics:(UIBarMetrics)barMetrics;

- (UIImage *)tableBackground;
- (UIImage *)tableSectionHeaderBackground;
- (UIImage *)tableFooterBackground;
- (UIImage *)viewBackground;
- (UIImage *)viewBackgroundPattern;
- (UIImage *)viewBackgroundTimeline;

- (UIImage *)switchOnImage;
- (UIImage *)switchOffImage;
- (UIImage *)switchOnIcon;
- (UIImage *)switchOffIcon;
- (UIImage *)switchTrack;
- (UIImage *)switchThumbForState:(UIControlState)state;

- (UIImage *)sliderThumbForState:(UIControlState)state;
- (UIImage *)sliderMinTrack;
- (UIImage *)sliderMaxTrack;
- (UIImage *)sliderMinTrackDouble;
- (UIImage *)sliderMaxTrackDouble;

- (UIImage *)progressTrackImage;
- (UIImage *)progressProgressImage;

- (UIImage *)progressPercentTrackImage;
- (UIImage *)progressPercentProgressImage;
- (UIImage *)progressPercentProgressValueImage;

- (UIImage *)stepperBackgroundForState:(UIControlState)state;
- (UIImage *)stepperDividerForState:(UIControlState)state;
- (UIImage *)stepperIncrementImage;
- (UIImage *)stepperDecrementImage;

- (UIImage *)buttonBackgroundForState:(UIControlState)state;

- (UIImage *)tabBarBackground;
- (UIImage *)tabBarSelectionIndicator;
// One of these must return a non-nil image for each tab:
- (UIImage *)imageForTab:(SSThemeTab)tab;
- (UIImage *)finishedImageForTab:(SSThemeTab)tab selected:(BOOL)selected;


@end

@interface ADVThemeManager : NSObject

+ (id <ADVTheme>)sharedTheme;

+ (void)customizeAppAppearance;
+ (void)customizeView:(UIView *)view;
+ (void)customizePatternView:(UIView *)view;
+ (void)customizeTimelineView:(UIView *)view;
+ (void)customizeTableView:(UITableView *)tableView;
+ (void)customizeTabBarItem:(UITabBarItem *)item forTab:(SSThemeTab)tab;
+ (void)customizeNavigationBar:(UINavigationBar *)navigationBar;
+ (void)customizeMainLabel:(UILabel *)label;
+ (void)customizeSecondaryLabel:(UILabel *)label;

@end
