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
    NSString*   functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignIn Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, item, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, item, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignIn Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, item, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, viewState, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@", group, screen, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@", group, type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@", group, type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@", type, attribute, controlStateString];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // Button Font
    functionName  = [NSString stringWithFormat:@"%@%@", type, attribute];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // Font
    functionName  = [NSString stringWithFormat:@"%@", attribute];
    if ([theme respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    DLog(LL_Debug, LD_Theming, @"No Function Called!");
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

+ (void)customizeView:(UIView*)view
            withGroup:(NSString*)group
            andScreen:(NSString*)screen
              andItem:(NSString*)item
{
    [[self class] customizeView:view withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeView:(UIView*)view
            withGroup:(NSString*)group
            andScreen:(NSString*)screen
         andViewState:(NSString*)viewState
              andItem:(NSString*)item
{
    view.layer.borderColor  = [[[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"View" andGroup:group andScreen:screen andViewState:viewState andItem:item] CGColor];
    view.layer.borderWidth  = [[[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"View" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    view.backgroundColor    = [[self class] performThemeSelectorForAttribute:@"BackgroundColor" withType:@"View" andGroup:group andScreen:screen andViewState:viewState andItem:item];
}

+ (void)customizeLabel:(DNLabel*)lblView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
               andItem:(NSString*)item
{
    [[self class] customizeLabel:lblView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeLabel:(DNLabel*)lblView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
          andViewState:(NSString*)viewState
               andItem:(NSString*)item
{
    lblView.layer.borderColor   = [[[self class] performThemeSelectorForAttribute:@"BorderColor"    withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] CGColor];
    lblView.layer.borderWidth   = [[[self class] performThemeSelectorForAttribute:@"BorderWidth"    withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    lblView.backgroundColor     = [[self class] performThemeSelectorForAttribute:@"BackgroundColor" withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSNumber*   labelKerning        = [[self class] performThemeSelectorForAttribute:@"Kerning"     withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIFont*     labelFont           = [[self class] performThemeSelectorForAttribute:@"Font"        withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIColor*    labelColor          = [[self class] performThemeSelectorForAttribute:@"Color"       withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   labelLineSpacing    = [[self class] performThemeSelectorForAttribute:@"LineSpacing" withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSMutableParagraphStyle*    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[labelLineSpacing intValue]];
    [paragraphStyle setAlignment:lblView.textAlignment];

    NSMutableAttributedString*  attrString  = [[lblView attributedText] mutableCopy];
    if ([attrString length] == 0)
    {
        if ([lblView.text length] > 0)
        {
            attrString  = [[NSMutableAttributedString alloc] initWithString:lblView.text];
        }
    }

    NSRange attrRange   = NSMakeRange(0, [attrString length]);

    [attrString removeAttribute:NSKernAttributeName range:attrRange];
    [attrString addAttribute:NSKernAttributeName value:labelKerning range:attrRange];

    [attrString removeAttribute:NSFontAttributeName range:attrRange];
    [attrString addAttribute:NSFontAttributeName value:labelFont range:attrRange];

    [attrString removeAttribute:NSForegroundColorAttributeName range:attrRange];
    [attrString addAttribute:NSForegroundColorAttributeName value:labelColor range:attrRange];

    [attrString removeAttribute:NSParagraphStyleAttributeName range:attrRange];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attrRange];

    [lblView setAttributedText:attrString];

    lblView.horizontalPadding   = [[[self class] performThemeSelectorForAttribute:@"HorizontalPadding"  withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
    lblView.verticalPadding     = [[[self class] performThemeSelectorForAttribute:@"VerticalPadding"    withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
}

+ (void)customizeImage:(UIImageView*)imgView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
               andItem:(NSString*)item
{
    [[self class] customizeImage:imgView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeImage:(UIImageView*)imgView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
          andViewState:(NSString*)viewState
               andItem:(NSString*)item
{
    imgView.layer.borderColor   = [[[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item] CGColor];
    imgView.layer.borderWidth   = [[[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    imgView.backgroundColor     = [[self class] performThemeSelectorForAttribute:@"BackgroundColor" withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
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

    txtfldView.backgroundColor      = [[self class] performThemeSelectorForAttribute:@"BackgroundColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    txtfldView.unhighlightedColor   = [[self class] performThemeSelectorForAttribute:@"UnhighlightedColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    txtfldView.highlightedColor     = [[self class] performThemeSelectorForAttribute:@"HighlightedColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    UIColor*    placeholderColor    = [[self class] performThemeSelectorForAttribute:@"PlaceholderColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    [txtfldView setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];

    txtfldView.horizontalPadding    = [[[self class] performThemeSelectorForAttribute:@"HorizontalPadding" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
    txtfldView.verticalPadding      = [[[self class] performThemeSelectorForAttribute:@"VerticalPadding" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    // Default is YES/nil if not specified, therefore, if != NO...
    if (![[[self class] performThemeSelectorForAttribute:@"ShowSuggestions" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] isEqual:@NO])
    {
        CGRect  attachmentViewFrame = CGRectMake(0, 0, [DNUtilities screenWidth], 32.0f);
        JTKeyboardAttachmentView*   attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
        [txtfldView setInputAccessoryView:attachmentView];
    }

    [txtfldView setNeedsLayout];
}

@end
