//
//  DNThemeManager.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <CoreText/CoreText.h>

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
                   andViewState:(NSString*)viewState
                        andItem:(NSString*)item
                andControlState:(UIControlState)controlState
{
    NSString*   controlStateString;
    if (controlState == UIControlStateNormal)
    {
        controlStateString  = @"";
    }
    else if (controlState == UIControlStateHighlighted)
    {
        controlStateString  = @"Highlighted";
    }
    else if (controlState == UIControlStateDisabled)
    {
        controlStateString  = @"Disabled";
    }
    else if (controlState == UIControlStateSelected)
    {
        controlStateString  = @"Selected";
    }

    id <DNThemeProtocol>    theme = [self sharedTheme];

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font Normal
    NSString*   retval  = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView SignIn Button Font Normal
    retval  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, item, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font Normal
    retval  = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font
    retval  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, item, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView SignIn Button Font
    retval  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, item, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView SignInWithKeyboard Button Font Normal
    retval  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView SignInWithKeyboard Button Font
    retval  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, viewState, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView Button Font Normal
    retval  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG WelcomeView Button Font
    retval  = [NSString stringWithFormat:@"%@%@%@%@", group, screen, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG Button Font Normal
    retval  = [NSString stringWithFormat:@"%@%@%@%@", group, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // LOG Button Font
    retval  = [NSString stringWithFormat:@"%@%@%@", group, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // Button Font Normal
    retval  = [NSString stringWithFormat:@"%@%@%@", type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // Button Font
    retval  = [NSString stringWithFormat:@"%@%@", type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(retval)] == YES)
    {
        return NSSelectorFromString(retval);
    }

    // Font
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
                          andViewState:(NSString*)viewState
                               andItem:(NSString*)item
{
    return [[self class] performThemeSelectorForAttribute:attribute withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];
}

+ (id)performThemeSelectorForAttribute:(NSString*)attribute
                              withType:(NSString*)type
                              andGroup:(NSString*)group
                             andScreen:(NSString*)screen
                          andViewState:(NSString*)viewState
                               andItem:(NSString*)item
                       andControlState:(UIControlState)controlState
{
    SEL aSelector   = [[self class] functionNameForAttribute:attribute
                                                    withType:type
                                                    andGroup:group
                                                   andScreen:screen
                                                andViewState:viewState
                                                     andItem:item
                                             andControlState:controlState];

    return [[self class] performThemeSelector:aSelector];
}

+ (NSString*)customizeNibNameWithClass:(NSString*)className
                             withGroup:(NSString*)group
                             andScreen:(NSString*)screen
{
    NSString*   retval  = [[self class] performThemeSelectorForAttribute:@"Name" withType:@"Nib" andGroup:group andScreen:screen andViewState:@"" andItem:@""];
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
    [[self class] customizeButton:btnView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeButtonLabel:(UIButton*)btnView
                   withGroup:(NSString*)group
                   andScreen:(NSString*)screen
                andViewState:(NSString*)viewState
                     andItem:(NSString*)item
             andControlState:(UIControlState)controlState
{
    NSNumber*   labelKerning    = [[self class] performThemeSelectorForAttribute:@"LabelKerning" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIFont*     labelFont       = [[self class] performThemeSelectorForAttribute:@"LabelFont" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIColor*    labelColor      = [[self class] performThemeSelectorForAttribute:@"LabelColor" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];

    NSMutableAttributedString*  attrString  = [[btnView attributedTitleForState:controlState] mutableCopy];
    NSRange                     attrRange   = NSMakeRange(0, [attrString length]);
    if ([attrString length] == 0)
    {
        attrString  = [[NSMutableAttributedString alloc] initWithString:btnView.titleLabel.text];
        attrRange   = NSMakeRange(0, [attrString length]);
    }

    [attrString removeAttribute:NSKernAttributeName range:attrRange];
    [attrString addAttribute:NSKernAttributeName value:labelKerning range:attrRange];

    [attrString removeAttribute:NSFontAttributeName range:attrRange];
    [attrString addAttribute:NSFontAttributeName value:labelFont range:attrRange];

    [attrString removeAttribute:NSForegroundColorAttributeName range:attrRange];
    [attrString addAttribute:NSForegroundColorAttributeName value:labelColor range:attrRange];
    [btnView setAttributedTitle:attrString forState:controlState];
}

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
           andViewState:(NSString*)viewState
                andItem:(NSString*)item
{
    btnView.layer.borderColor   = [[[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item] CGColor];
    btnView.layer.borderWidth   = [[[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    btnView.backgroundColor     = [[self class] performThemeSelectorForAttribute:@"BackgroundColor" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    [[self class] customizeButtonLabel:btnView withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];
    [[self class] customizeButtonLabel:btnView withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateHighlighted];
    [[self class] customizeButtonLabel:btnView withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateDisabled];
    [[self class] customizeButtonLabel:btnView withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateSelected];

    NSNumber*   labelKerning    = [[self class] performThemeSelectorForAttribute:@"LabelKerning" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    [btnView.titleLabel setKerning:[labelKerning doubleValue]];
}

+ (void)customizeTextField:(DNTextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
                   andItem:(NSString*)item
{
    [[self class] customizeTextField:txtfldView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeTextField:(DNTextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
              andViewState:(NSString*)viewState
                   andItem:(NSString*)item
{
    txtfldView.font                 = [[self class] performThemeSelectorForAttribute:@"Font" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    txtfldView.layer.borderColor    = [[[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] CGColor];
    txtfldView.layer.borderWidth    = [[[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    UIColor*    placeholderColor    = [[self class] performThemeSelectorForAttribute:@"PlaceholderColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    [txtfldView setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];

    txtfldView.horizontalPadding    = [[[self class] performThemeSelectorForAttribute:@"HorizontalPadding" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
    txtfldView.verticalPadding      = [[[self class] performThemeSelectorForAttribute:@"VerticalPadding" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
}

@end
