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
    [[self class] customizeView:view withType:@"View" andGroup:group andScreen:screen andViewState:viewState andItem:item];
}

+ (void)customizeView:(UIView*)view
             withType:(NSString*)type
             andGroup:(NSString*)group
            andScreen:(NSString*)screen
         andViewState:(NSString*)viewState
              andItem:(NSString*)item
{
    [[self class] customizeView:view withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];
}

+ (void)customizeView:(UIView*)view
             withType:(NSString*)type
             andGroup:(NSString*)group
            andScreen:(NSString*)screen
         andViewState:(NSString*)viewState
              andItem:(NSString*)item
      andControlState:(UIControlState)controlState
{
    view.layer.borderColor  = [[[self class] performThemeSelectorForAttribute:@"BorderColor"    withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState] CGColor];
    view.layer.borderWidth  = [[[self class] performThemeSelectorForAttribute:@"BorderWidth"    withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState] doubleValue];

    view.tintColor          = [[self class] performThemeSelectorForAttribute:@"TintColor"       withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    view.backgroundColor    = [[self class] performThemeSelectorForAttribute:@"BackgroundColor" withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
}

+ (NSAttributedString*)labelAttributedString:(UILabel*)lblView
                                    withType:(NSString*)type
                                    andGroup:(NSString*)group
                                   andScreen:(NSString*)screen
                                andViewState:(NSString*)viewState
                                     andItem:(NSString*)item
                             andControlState:(UIControlState)controlState
{
    NSNumber*   labelKerning        = [[self class] performThemeSelectorForAttribute:@"Kerning"     withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIFont*     labelFont           = [[self class] performThemeSelectorForAttribute:@"Font"        withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIColor*    labelColor          = [[self class] performThemeSelectorForAttribute:@"Color"       withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    NSNumber*   labelLineSpacing    = [[self class] performThemeSelectorForAttribute:@"LineSpacing" withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];

    lblView.textAlignment           = [[[self class] performThemeSelectorForAttribute:@"TextAlignment"   withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState] intValue];

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

    return attrString;
}

+ (void)customizeLabel:(UILabel*)lblView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
               andItem:(NSString*)item
{
    [[self class] customizeLabel:lblView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeLabel:(UILabel*)lblView
             withGroup:(NSString*)group
             andScreen:(NSString*)screen
          andViewState:(NSString*)viewState
               andItem:(NSString*)item
{
    [[self class] customizeView:lblView withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];

    if ([lblView isKindOfClass:[DNLabel class]])
    {
        ((DNLabel*)lblView).verticalAlignment   = [[[self class] performThemeSelectorForAttribute:@"VerticalAlignment"  withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] intValue];
        ((DNLabel*)lblView).lineHeightMultiple  = [[[self class] performThemeSelectorForAttribute:@"LineHeightMultiple" withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] intValue];
    }

    NSAttributedString* attrString  = [[self class] labelAttributedString:lblView
                                                                 withType:@"Label"
                                                                 andGroup:group
                                                                andScreen:screen
                                                             andViewState:viewState
                                                                  andItem:item
                                                          andControlState:UIControlStateNormal];
    [lblView setAttributedText:attrString];

    if ([lblView isKindOfClass:[DNLabel class]])
    {
        ((DNLabel*)lblView).horizontalPadding   = [[[self class] performThemeSelectorForAttribute:@"HorizontalPadding"  withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
        ((DNLabel*)lblView).verticalPadding     = [[[self class] performThemeSelectorForAttribute:@"VerticalPadding"    withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
    }
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
    [[self class] customizeView:imgView withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    if ([imgView isKindOfClass:[NZCircularImageView class]])
    {
        UIColor*    borderColor = [[self class] performThemeSelectorForAttribute:@"BorderColor" withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        NSNumber*   borderWidth = [[self class] performThemeSelectorForAttribute:@"BorderWidth" withType:@"ImageView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

        ((NZCircularImageView*)imgView).borderColor = borderColor;
        ((NZCircularImageView*)imgView).borderWidth = borderWidth;
    }
}

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
                andItem:(NSString*)item
{
    [[self class] customizeButton:btnView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeButton:(UIButton*)btnView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
           andViewState:(NSString*)viewState
                andItem:(NSString*)item
{
    [[self class] customizeView:btnView withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];

    {
        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                                     withType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateNormal];
        [btnView setAttributedTitle:attrString forState:UIControlStateNormal];
    }
    {
        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                                     withType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateHighlighted];
        [btnView setAttributedTitle:attrString forState:UIControlStateHighlighted];
    }
    {
        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                                     withType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateDisabled];
        [btnView setAttributedTitle:attrString forState:UIControlStateDisabled];
    }
    {
        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                                     withType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateSelected];
        [btnView setAttributedTitle:attrString forState:UIControlStateSelected];
    }
}

+ (void)customizeTextField:(UITextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
                   andItem:(NSString*)item
{
    [[self class] customizeTextField:txtfldView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeTextField:(UITextField*)txtfldView
                 withGroup:(NSString*)group
                 andScreen:(NSString*)screen
              andViewState:(NSString*)viewState
                   andItem:(NSString*)item
{
    [[self class] customizeView:txtfldView withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];

    txtfldView.font                 = [[self class] performThemeSelectorForAttribute:@"Font" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    txtfldView.borderStyle          = [[[self class] performThemeSelectorForAttribute:@"BorderStyle" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] integerValue];

    UIColor*    placeholderColor    = [[self class] performThemeSelectorForAttribute:@"PlaceholderColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    [txtfldView setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];

    if ([txtfldView isKindOfClass:[DNTextField class]])
    {
        ((DNTextField*)txtfldView).unhighlightedColor   = [[self class] performThemeSelectorForAttribute:@"UnhighlightedColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        ((DNTextField*)txtfldView).highlightedColor     = [[self class] performThemeSelectorForAttribute:@"HighlightedColor" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];

        ((DNTextField*)txtfldView).horizontalPadding    = [[[self class] performThemeSelectorForAttribute:@"HorizontalPadding" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];
        ((DNTextField*)txtfldView).verticalPadding      = [[[self class] performThemeSelectorForAttribute:@"VerticalPadding" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

        // Default is YES/nil if not specified, therefore, if != NO...
        if (![[[self class] performThemeSelectorForAttribute:@"ShowSuggestions" withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] isEqual:@NO])
        {
            CGRect  attachmentViewFrame = CGRectMake(0, 0, [DNUtilities screenWidth], 32.0f);
            JTKeyboardAttachmentView*   attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
            [txtfldView setInputAccessoryView:attachmentView];
        }
    }

    [txtfldView setNeedsLayout];
}

+ (void)customizeTextView:(UITextView*)txtView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
                  andItem:(NSString*)item
{
    [[self class] customizeTextView:txtView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeTextView:(UITextView*)txtView
                withGroup:(NSString*)group
                andScreen:(NSString*)screen
             andViewState:(NSString*)viewState
                  andItem:(NSString*)item
{
    [[self class] customizeView:txtView withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];

    txtView.font    = [[self class] performThemeSelectorForAttribute:@"Font" withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    if ([txtView isKindOfClass:[DNTextView class]])
    {
        ((DNTextView*)txtView).realTextColor    = [[self class] performThemeSelectorForAttribute:@"Color"             withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        ((DNTextView*)txtView).placeholderColor = [[self class] performThemeSelectorForAttribute:@"PlaceholderColor"  withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

        // Default is YES/nil if not specified, therefore, if != NO...
        if (![[[self class] performThemeSelectorForAttribute:@"ShowSuggestions" withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item] isEqual:@NO])
        {
            CGRect  attachmentViewFrame = CGRectMake(0, 0, [DNUtilities screenWidth], 32.0f);
            JTKeyboardAttachmentView*   attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
            [txtView setInputAccessoryView:attachmentView];
        }
    }

    [txtView setNeedsLayout];
}

+ (void)customizeSegmentedControl:(UISegmentedControl*)segmentedControl
                        withGroup:(NSString*)group
                        andScreen:(NSString*)screen
                          andItem:(NSString*)item
{
    [[self class] customizeSegmentedControl:segmentedControl withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeSegmentedControl:(UISegmentedControl*)segmentedControl
                        withGroup:(NSString*)group
                        andScreen:(NSString*)screen
                     andViewState:(NSString*)viewState
                          andItem:(NSString*)item
{
    [[self class] customizeView:segmentedControl withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];

    if ([segmentedControl isKindOfClass:[DNSegmentedControl class]])
    {
        segmentedControl.layer.borderColor  = [[UIColor clearColor] CGColor];
        segmentedControl.layer.borderWidth  = 0.0f;

        ((DNSegmentedControl*)segmentedControl).color           = [[self class] performThemeSelectorForAttribute:@"BackgroundColor"         withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        ((DNSegmentedControl*)segmentedControl).selectedColor   = [[self class] performThemeSelectorForAttribute:@"SelectedBackgroundColor" withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];

        ((DNSegmentedControl*)segmentedControl).borderColor     = [[self class] performThemeSelectorForAttribute:@"BorderColor"     withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        ((DNSegmentedControl*)segmentedControl).borderWidth     = [[[self class] performThemeSelectorForAttribute:@"BorderWidth"    withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

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

        ((DNSegmentedControl*)segmentedControl).textAttributes = textAttributes;

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
        
        ((DNSegmentedControl*)segmentedControl).selectedTextAttributes = selectedTextAttributes;
    }
}

+ (void)customizeBarButtonItem:(UIBarButtonItem*)barButtonItem
                     withGroup:(NSString*)group
                     andScreen:(NSString*)screen
                       andItem:(NSString*)item
{
    [[self class] customizeBarButtonItem:barButtonItem withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeBarButtonItem:(UIBarButtonItem*)barButtonItem
                     withGroup:(NSString*)group
                     andScreen:(NSString*)screen
                  andViewState:(NSString*)viewState
                       andItem:(NSString*)item
               andControlState:(UIControlState)controlState
{
    NSNumber*   labelKerning    = [[self class] performThemeSelectorForAttribute:@"Kerning" withType:@"BarButtonItem" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIFont*     labelFont       = [[self class] performThemeSelectorForAttribute:@"Font" withType:@"BarButtonItem" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIColor*    labelColor      = [[self class] performThemeSelectorForAttribute:@"Color" withType:@"BarButtonItem" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];

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
    [[self class] customizeBarButtonItem:barButtonItem withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];
    [[self class] customizeBarButtonItem:barButtonItem withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateHighlighted];
    [[self class] customizeBarButtonItem:barButtonItem withGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateDisabled];
}

+ (void)customizeSwitch:(UISwitch*)switchView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
                andItem:(NSString*)item
{
    [[self class] customizeSwitch:switchView withGroup:group andScreen:screen andViewState:@"" andItem:item];
}

+ (void)customizeSwitch:(UISwitch*)switchView
              withGroup:(NSString*)group
              andScreen:(NSString*)screen
           andViewState:(NSString*)viewState
                andItem:(NSString*)item
{
    [[self class] customizeView:switchView withType:@"Switch" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];

    switchView.onTintColor      = [[self class] performThemeSelectorForAttribute:@"OnTintColor" withType:@"SwitchView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    switchView.thumbTintColor   = [[self class] performThemeSelectorForAttribute:@"ThumbTintColor" withType:@"SwitchView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
}

@end
