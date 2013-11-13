//
//  DNThemeManager.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNThemeManager.h"

#import "DNTheme.h"
#import "DNUtilities.h"

#import "UILabel+TextKerning.h"

@implementation DNThemeManager

+ (NSString*)themeName
{
    return @"DNTheme";
}

+ (id <DNThemeProtocol>)sharedTheme
{
    static id <DNThemeProtocol> sharedTheme = nil;
    static dispatch_once_t      onceToken;

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
                       andState:(NSString*)state
                        andItem:(NSString*)item
{
    id <DNThemeProtocol>    theme = [self sharedTheme];

    NSString*   retval  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, state, item, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, item, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, state, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@%@", group, screen, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@%@", group, state, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@", group, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@%@", state, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@", type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    retval  = [NSString stringWithFormat:@"%@%@", state, attribute];
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

+ (id)performThemeSelector:(SEL)aSelector
{
    if (aSelector == nil)   {   return nil; }

    id <ADVTheme>   theme = [self sharedTheme];

    return [theme performSelector:aSelector];
}

#pragma clang diagnostic pop

+ (id)performThemeSelectorForAttribute:(NSString*)attribute
                              withType:(NSString*)type
                              andGroup:(NSString*)group
                             andScreen:(NSString*)screen
                               andItem:(NSString*)item
{
    return [[self class] performThemeSelectorForAttribute:attribute withType:type andGroup:group andScreen:screen andState:@"" andItem:item];
}

+ (id)performThemeSelectorForAttribute:(NSString*)attribute
                              withType:(NSString*)type
                              andGroup:(NSString*)group
                             andScreen:(NSString*)screen
                              andState:(NSString*)state
                               andItem:(NSString*)item
{
    SEL aSelector   = [[self class] functionNameForAttribute:attribute
                                                    withType:type
                                                    andGroup:group
                                                   andScreen:screen
                                                    andState:state
                                                     andItem:item];

    return [[self class] performThemeSelector:aSelector];
}

+ (NSString*)customizeNibNameWithClass:(NSString*)className
                             withGroup:(NSString*)group
                             andScreen:(NSString*)screen
{
    NSString*   retval  = [[self class] performThemeSelectorForAttribute:@"Name" withType:@"Nib" andGroup:group andScreen:screen andItem:@""];
    if (retval == nil)
    {
        retval = className;
    }

    return [DNUtilities appendNibSuffix:retval];
}

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
                andItem:(NSString*)item
{
    [[self class] customizeButton:btnView withGroup:group andScreen:screen andState:@"" andItem:item];
}

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
               andState:(NSString*)state
                andItem:(NSString*)item
{
    [btnView.titleLabel setKerning:[[[self class] performThemeSelectorForAttribute:@"LabelKerning" withType:@"Button" andGroup:group andScreen:screen andState:state andItem:item] doubleValue]];

    btnView.titleLabel.font     = [[self class] performThemeSelectorForAttribute:@"Font" withType:@"Button" andGroup:group andScreen:screen andState:state andItem:item];
    btnView.layer.borderColor   = [[[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"Button" andGroup:group andScreen:screen andState:state andItem:item] CGColor];
    btnView.layer.borderWidth   = [[[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"Button" andGroup:group andScreen:screen andState:state andItem:item] doubleValue];
}

+ (void)customizeTextField:(DNTextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
                   andItem:(NSString*)item
{
    [[self class] customizeTextField:txtfldView withGroup:group andScreen:screen andState:@"" andItem:item];
}

+ (void)customizeTextField:(DNTextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
                  andState:(NSString*)state
                   andItem:(NSString*)item
{
    txtfldView.font                 = [[self class] performThemeSelectorForAttribute:@"Font" withType:@"TextField" andGroup:group andScreen:screen andState:state andItem:item];
    txtfldView.layer.borderColor    = [[[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"TextField" andGroup:group andScreen:screen andState:state andItem:item] CGColor];
    txtfldView.layer.borderWidth    = [[[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"TextField" andGroup:group andScreen:screen andState:state andItem:item] doubleValue];

    txtfldView.horizontalPadding    = [[[self class] performThemeSelectorForAttribute:@"HorizontalPadding" withType:@"TextField" andGroup:group andScreen:screen andState:state andItem:item] doubleValue];
    txtfldView.verticalPadding      = [[[self class] performThemeSelectorForAttribute:@"VerticalPadding" withType:@"TextField" andGroup:group andScreen:screen andState:state andItem:item] doubleValue];

    UIColor*    placeholderColor    = [[self class] performThemeSelectorForAttribute:@"PlaceholderColor" withType:@"TextField" andGroup:group andScreen:screen andState:state andItem:item];
    [txtfldView setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

@end
