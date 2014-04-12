//
//  DNThemeManager.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <CoreText/CoreText.h>

#import "DNThemeManager.h"

#import "DNTheme.h"
#import "DNUtilities.h"

#import "DNTextView.h"
#import "DNTextField.h"
#import "DNLabel.h"
#import "DNSegmentedControl.h"

#import "UILabel+TextKerning.h"
#import "NZCircularImageView.h"

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
                      if (!sharedTheme)
                      {
                          NSException*    exception = [NSException exceptionWithName:@"DNThemeManager Exception"
                                                                              reason:@"sharedTheme is missing!"
                                                                            userInfo:nil];
                          @throw exception;
                      }
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

    lblView.verticalAlignment   = [[[self class] performThemeSelectorForAttribute:@"VerticalAlignment"  withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] intValue];
    lblView.lineHeightMultiple  = [[[self class] performThemeSelectorForAttribute:@"LineHeightMultiple" withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] intValue];

    NSNumber*   labelKerning        = [[self class] performThemeSelectorForAttribute:@"Kerning"     withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIFont*     labelFont           = [[self class] performThemeSelectorForAttribute:@"Font"        withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIColor*    labelColor          = [[self class] performThemeSelectorForAttribute:@"Color"       withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   labelLineSpacing    = [[self class] performThemeSelectorForAttribute:@"LineSpacing" withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSTextAlignment labelTextAlignment  = [[[self class] performThemeSelectorForAttribute:@"TextAlignment"   withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] intValue];

    NSMutableParagraphStyle*    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[labelLineSpacing intValue]];
    [paragraphStyle setAlignment:labelTextAlignment];

    NSMutableAttributedString*  attrString  = [[lblView attributedText] mutableCopy];
    if ([attrString length] == 0)
    {
        if ([lblView.text length] > 0)
        {
            attrString  = [[NSMutableAttributedString alloc] initWithString:lblView.text];
        }
    }

    NSRange attrRange   = NSMakeRange(0, [attrString length]);

    if (labelKerning)
    {
        [attrString removeAttribute:NSKernAttributeName range:attrRange];
        [attrString addAttribute:NSKernAttributeName value:labelKerning range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/Label/Kerning is not specified!", group, screen, viewState, item);
    }
    if (labelFont)
    {
        [attrString removeAttribute:NSFontAttributeName range:attrRange];
        [attrString addAttribute:NSFontAttributeName value:labelFont range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/Label/Font is not specified!", group, screen, viewState, item);
    }
    if (labelColor)
    {
        [attrString removeAttribute:NSForegroundColorAttributeName range:attrRange];
        [attrString addAttribute:NSForegroundColorAttributeName value:labelColor range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/Label/Color is not specified!", group, screen, viewState, item);
    }

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
    UIColor*    borderColor = [[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   borderWidth = [[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    if ([imgView isKindOfClass:[NZCircularImageView class]])
    {
        ((NZCircularImageView*)imgView).borderColor = borderColor;
        ((NZCircularImageView*)imgView).borderWidth = borderWidth;
    }
    else
    {
        imgView.layer.borderColor   = [borderColor CGColor];
        imgView.layer.borderWidth   = [borderWidth doubleValue];
    }

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

    if (labelKerning)
    {
        [attrString removeAttribute:NSKernAttributeName range:attrRange];
        [attrString addAttribute:NSKernAttributeName value:labelKerning range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/%d/Button/LabelKerning is not specified!", group, screen, viewState, item, controlState);
    }
    if (labelFont)
    {
        [attrString removeAttribute:NSFontAttributeName range:attrRange];
        [attrString addAttribute:NSFontAttributeName value:labelFont range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/%d/Button/LabelFont is not specified!", group, screen, viewState, item, controlState);
    }
    if (labelColor)
    {
        [attrString removeAttribute:NSForegroundColorAttributeName range:attrRange];
        [attrString addAttribute:NSForegroundColorAttributeName value:labelColor range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/%d/Button/LabelColor is not specified!", group, screen, viewState, item, controlState);
    }

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

+ (void)customizeTextView:(DNTextView*)txtView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
                  andItem:(NSString*)item
{
    [[self class] customizeTextView:txtView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeTextView:(DNTextView*)txtView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
             andViewState:(NSString*)viewState
                  andItem:(NSString*)item
{
    txtView.layer.borderColor   = [[[self class] performThemeSelectorForAttribute:@"BorderColor"        withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item] CGColor];
    txtView.layer.borderWidth   = [[[self class] performThemeSelectorForAttribute:@"BorderWidth"        withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    txtView.placeholderColor    = [[self class] performThemeSelectorForAttribute:@"PlaceholderColor"    withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    txtView.backgroundColor     = [[self class] performThemeSelectorForAttribute:@"BackgroundColor"     withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSNumber*   txtViewKerning      = [[self class] performThemeSelectorForAttribute:@"Kerning"     withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIFont*     txtViewFont         = [[self class] performThemeSelectorForAttribute:@"Font"        withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIColor*    txtViewColor        = [[self class] performThemeSelectorForAttribute:@"Color"       withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   txtViewLineSpacing  = [[self class] performThemeSelectorForAttribute:@"LineSpacing" withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSMutableParagraphStyle*    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[txtViewLineSpacing intValue]];
    [paragraphStyle setAlignment:txtView.textAlignment];

    NSMutableAttributedString*  attrString  = [[txtView attributedText] mutableCopy];
    if ([attrString length] == 0)
    {
        if ([txtView.text length] > 0)
        {
            attrString  = [[NSMutableAttributedString alloc] initWithString:txtView.text];
        }
    }

    NSRange attrRange   = NSMakeRange(0, [attrString length]);

    if (txtViewKerning)
    {
        [attrString removeAttribute:NSKernAttributeName range:attrRange];
        [attrString addAttribute:NSKernAttributeName value:txtViewKerning range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/TextView/Kerning is not specified!", group, screen, viewState, item);
    }
    if (txtViewFont)
    {
        [attrString removeAttribute:NSFontAttributeName range:attrRange];
        [attrString addAttribute:NSFontAttributeName value:txtViewFont range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/TextView/Font is not specified!", group, screen, viewState, item);
    }
    if (txtViewColor)
    {
        [attrString removeAttribute:NSForegroundColorAttributeName range:attrRange];
        [attrString addAttribute:NSForegroundColorAttributeName value:txtViewColor range:attrRange];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/TextView/Color is not specified!", group, screen, viewState, item);
    }

    [attrString removeAttribute:NSParagraphStyleAttributeName range:attrRange];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attrRange];

    [txtView setAttributedText:attrString];

    // Default is YES/nil if not specified, therefore, if != NO...
    if (![[[self class] performThemeSelectorForAttribute:@"ShowSuggestions" withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item] isEqual:@NO])
    {
        CGRect  attachmentViewFrame = CGRectMake(0, 0, [DNUtilities screenWidth], 32.0f);
        JTKeyboardAttachmentView*   attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
        [txtView setInputAccessoryView:attachmentView];
    }

    [txtView setNeedsLayout];
}

+ (void)customizeSegmentedControl:(DNSegmentedControl*)segmentedControl
                        withGroup:(NSString*)group
                        andScreen:(NSString*)screen
                          andItem:(NSString*)item
{
    [[self class] customizeSegmentedControl:segmentedControl withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeSegmentedControl:(DNSegmentedControl*)segmentedControl
                        withGroup:(NSString*)group
                        andScreen:(NSString*)screen
                     andViewState:(NSString*)viewState
                          andItem:(NSString*)item
{
    segmentedControl.color          = [[self class] performThemeSelectorForAttribute:@"BackgroundColor"         withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    segmentedControl.selectedColor  = [[self class] performThemeSelectorForAttribute:@"SelectedBackgroundColor" withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    segmentedControl.borderColor    = [[self class] performThemeSelectorForAttribute:@"BorderColor"     withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    segmentedControl.borderWidth    = [[[self class] performThemeSelectorForAttribute:@"BorderWidth"    withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    NSNumber*   textAttributesKerning   = [[self class] performThemeSelectorForAttribute:@"Kerning"     withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIFont*     textAttributesFont      = [[self class] performThemeSelectorForAttribute:@"Font"        withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIColor*    textAttributesColor     = [[self class] performThemeSelectorForAttribute:@"Color"       withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSMutableDictionary*    textAttributes  = [NSMutableDictionary dictionary];
    if (textAttributesKerning)
    {
        [textAttributes setObject:textAttributesKerning forKey:NSKernAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/SegmentedControl/Kerning is not specified!", group, screen, viewState, item);
    }
    if (textAttributesFont)
    {
        [textAttributes setObject:textAttributesFont forKey:NSFontAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/SegmentedControl/Font is not specified!", group, screen, viewState, item);
    }
    if (textAttributesColor)
    {
        [textAttributes setObject:textAttributesColor forKey:NSForegroundColorAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/SegmentedControl/Color is not specified!", group, screen, viewState, item);
    }

    segmentedControl.textAttributes = textAttributes;

    NSNumber*   selectedTextAttributesKerning   = [[self class] performThemeSelectorForAttribute:@"SelectedKerning" withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIFont*     selectedTextAttributesFont      = [[self class] performThemeSelectorForAttribute:@"SelectedFont"    withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIColor*    selectedTextAttributesColor     = [[self class] performThemeSelectorForAttribute:@"SelectedColor"   withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSMutableDictionary*    selectedTextAttributes  = [NSMutableDictionary dictionary];
    if (selectedTextAttributesKerning)
    {
        [selectedTextAttributes setObject:textAttributesKerning forKey:NSKernAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/SegmentedControl/SelectedKerning is not specified!", group, screen, viewState, item);
    }
    if (selectedTextAttributesFont)
    {
        [selectedTextAttributes setObject:selectedTextAttributesFont forKey:NSFontAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/SegmentedControl/SelectedFont is not specified!", group, screen, viewState, item);
    }
    if (selectedTextAttributesColor)
    {
        [selectedTextAttributes setObject:selectedTextAttributesColor forKey:NSForegroundColorAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/SegmentedControl/SelectedColor is not specified!", group, screen, viewState, item);
    }

    segmentedControl.selectedTextAttributes = selectedTextAttributes;
}

+ (void)customizeBarButtonItem:(UIBarButtonItem*)barButtonItem
                     withGroup:(NSString*)group
                     andScreen:(NSString*)screen
                       andItem:(NSString*)item
{
    [[self class] customizeBarButtonItem:barButtonItem withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeBarButtonItemLabel:(UIBarButtonItem*)barButtonItem
                          withGroup:(NSString*)group
                          andScreen:(NSString*)screen
                       andViewState:(NSString*)viewState
                            andItem:(NSString*)item
                    andControlState:(UIControlState)controlState
{
    NSNumber*   labelKerning    = [[self class] performThemeSelectorForAttribute:@"LabelKerning" withType:@"BarButtonItem" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIFont*     labelFont       = [[self class] performThemeSelectorForAttribute:@"LabelFont" withType:@"BarButtonItem" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIColor*    labelColor      = [[self class] performThemeSelectorForAttribute:@"LabelColor" withType:@"BarButtonItem" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];

    NSMutableDictionary*    textAttributes  = [NSMutableDictionary dictionary];
    if (labelKerning)
    {
        [textAttributes setObject:labelKerning forKey:NSKernAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/%d/BarButtonItem/LabelKerning is not specified!", group, screen, viewState, item, controlState);
    }
    if (labelFont)
    {
        [textAttributes setObject:labelFont forKey:NSFontAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/%d/BarButtonItem/LabelFont is not specified!", group, screen, viewState, item, controlState);
    }
    if (labelColor)
    {
        [textAttributes setObject:labelColor forKey:NSForegroundColorAttributeName];
    }
    else
    {
        DLog(LL_Error, LD_Theming, @"%@/%@/%@/%@/%d/BarButtonItem/LabelColor is not specified!", group, screen, viewState, item, controlState);
    }

    [barButtonItem setTitleTextAttributes:textAttributes
                                 forState:controlState];
}

+ (void)customizeBarButtonItem:(UIBarButtonItem*)barButtonItem
                     withGroup:(NSString*)group
                     andScreen:(NSString*)screen
                  andViewState:(NSString*)viewState
                       andItem:(NSString*)item
{
    [[self class] customizeBarButtonItemLabel:barButtonItem withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];
    [[self class] customizeBarButtonItemLabel:barButtonItem withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateHighlighted];
    [[self class] customizeBarButtonItemLabel:barButtonItem withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateDisabled];
}

@end
