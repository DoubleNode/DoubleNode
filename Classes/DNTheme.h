//
//  DNTheme.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADVTheme.h"

@protocol DNTheme <ADVTheme, NSObject>

@end

@interface DNThemeManager : ADVThemeManager

+ (NSString*)themeName;
+ (id <DNTheme>)sharedTheme;

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
                andItem:(NSString*)item;

@end
