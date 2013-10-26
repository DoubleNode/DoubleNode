//
//  DNTheme.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNTheme.h"

#import "DNBaseTheme.h"

#import "UILabel+TextKerning.h"

#import "CDOConstant.h"

@implementation DNThemeManager

+ (NSString*)themeName
{
    NSString*   retval  = [AppConstants appTheme];
    if ([retval length] == 0)
    {
        retval = @"Base";
    }

    return [NSString stringWithFormat:@"DN%@Theme", retval];
}

+ (id <DNTheme>)sharedTheme
{
    static id <DNTheme>     sharedTheme = nil;
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^
                  {
                      // Create and return the theme:
                      sharedTheme = [[NSClassFromString([[self class] themeName]) alloc] init];
                  });
    
    return sharedTheme;
}

+ (SEL)functionNameForAttribute:(NSString*)attribute
                       withType:(NSString*)type
                       andGroup:(NSString*)group
                      andScreen:(NSString*)screen
                        andItem:(NSString*)item
{
    id <DNTheme>    theme = [self sharedTheme];

    NSString*   retval  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, item, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@%@", group, screen, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@", group, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@", type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@", attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    return nil;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
                andItem:(NSString*)item
{
    id <ADVTheme>   theme = [self sharedTheme];

    btnView.titleLabel.font     = [theme performSelector:[[self class] functionNameForAttribute:@"Font" withType:@"Button" andGroup:group andScreen:screen andItem:item]];
    [btnView.titleLabel setKerning:[[theme performSelector:[[self class] functionNameForAttribute:@"LabelKerning" withType:@"Button" andGroup:group andScreen:screen andItem:item]] doubleValue]];
    btnView.layer.borderColor   = [[theme performSelector:[[self class] functionNameForAttribute:@"BorderColor" withType:@"Button" andGroup:group andScreen:screen andItem:item]] CGColor];
    btnView.layer.borderWidth   = [[theme performSelector:[[self class] functionNameForAttribute:@"BorderWidth" withType:@"Button" andGroup:group andScreen:screen andItem:item]] doubleValue];

    DLog(LL_Debug, LD_General, @"BorderWidth=%@", [theme performSelector:[[self class] functionNameForAttribute:@"BorderWidth" withType:@"Button" andGroup:group andScreen:screen andItem:item]]);
}

#pragma clang diagnostic pop

@end
