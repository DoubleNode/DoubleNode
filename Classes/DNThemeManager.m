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
#import "DNButton.h"
#import "DNSegmentedControl.h"

#import "UILabel+TextKerning.h"
#import "NZCircularImageView.h"

@interface DNAttributedStringAttribute : NSObject

@property (nonatomic, retain) NSDictionary* attributes;
@property (nonatomic, assign) NSRange       range;

@end

@implementation DNAttributedStringAttribute

@end

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

+ (NSCache*)sharedCache
{
    static NSCache*         sharedCache = nil;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^
                  {
                      // Create and return the cache:
                      sharedCache       = [[NSCache alloc] init];
                      sharedCache.name  = @"com.doublenode.dnthememanager.cache";
                      if (!sharedCache)
                      {
                          NSException*    exception = [NSException exceptionWithName:@"DNThemeManager Exception"
                                                                              reason:@"sharedCache is missing!"
                                                                            userInfo:nil];
                          @throw exception;
                      }
                  });
    
    return sharedCache;
}

+ (UIColor*)primaryColor
{
    id <DNThemeProtocol>    theme = [self sharedTheme];

    return [theme primaryColor];
}

+ (UIColor*)secondaryColor
{
    id <DNThemeProtocol>    theme = [self sharedTheme];

    return [theme secondaryColor];
}

+ (void)resetCache
{
    id <DNThemeProtocol>    theme = [self sharedTheme];

    [theme resetCache];
    
    NSCache*    cache   = [self sharedCache];
    [cache removeAllObjects];
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

    return [theme functionNameForAttribute:attribute withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlStateString];
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

+ (NSString*)controlStateString:(UIControlState)controlState
{
    NSString*   controlStateString;

    switch (controlState)
    {
        case UIControlStateNormal:      {   controlStateString  = @"UIControlStateNormal";      break;  }
        case UIControlStateHighlighted: {   controlStateString  = @"UIControlStateHighlighted"; break;  }
        case UIControlStateDisabled:    {   controlStateString  = @"UIControlStateDisabled";    break;  }
        case UIControlStateSelected:    {   controlStateString  = @"UIControlStateSelected";    break;  }

        default:
        {
            controlStateString  = [NSString stringWithFormat:@"%lu", controlState];
            break;
        }
    }

    return controlStateString;
}

+ (id)performThemeSelectorForAttribute:(NSString*)attribute
                              withType:(NSString*)type
                              andGroup:(NSString*)group
                             andScreen:(NSString*)screen
                          andViewState:(NSString*)viewState
                               andItem:(NSString*)item
                       andControlState:(UIControlState)controlState
{
    NSString*   cacheKey    = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, [self controlStateString:controlState]];

    id  retval  = [[self sharedCache] objectForKey:cacheKey];
    if (retval)
    {
        return retval;
    }
    
    SEL aSelector   = [[self class] functionNameForAttribute:attribute
                                                    withType:type
                                                    andGroup:group
                                                   andScreen:screen
                                                andViewState:viewState
                                                     andItem:item
                                             andControlState:controlState];
    
    if (!aSelector)
    {
        DLog(LL_Error, LD_Theming, @"No valid selector found! (%@/%@/%@/%@/%@/%@/%@)", attribute, type, group, screen, viewState, item, [[self class] controlStateString:controlState]);
        return nil;
    }
    
    retval = [[self class] performThemeSelector:aSelector];
    if (!retval)
    {
        DLog(LL_Error, LD_Theming, @"%@ returned nil! (%@/%@/%@/%@/%@/%@/%@)", NSStringFromSelector(aSelector), attribute, type, group, screen, viewState, item, [[self class] controlStateString:controlState]);
    }
    else
    {
        [[self sharedCache] setObject:retval forKey:cacheKey cost:sizeof(retval)];
    }

    return retval;
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
                        withAttributedString:(NSAttributedString*)attributedString
                                     andType:(NSString*)type
                                    andGroup:(NSString*)group
                                   andScreen:(NSString*)screen
                                andViewState:(NSString*)viewState
                                     andItem:(NSString*)item
                             andControlState:(UIControlState)controlState
{
    NSNumber*   labelKerning        = [[self class] performThemeSelectorForAttribute:@"Kerning"             withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIFont*     labelFont           = [[self class] performThemeSelectorForAttribute:@"Font"                withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    UIColor*    labelColor          = [[self class] performThemeSelectorForAttribute:@"Color"               withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    NSNumber*   labelLineSpacing    = [[self class] performThemeSelectorForAttribute:@"LineSpacing"         withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState];
    NSNumber*   lineHeightMultiple  = [[self class] performThemeSelectorForAttribute:@"LineHeightMultiple"  withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item  andControlState:controlState];

    lblView.textAlignment           = [[[self class] performThemeSelectorForAttribute:@"TextAlignment"      withType:type andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:controlState] intValue];

    NSMutableParagraphStyle*    paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[labelLineSpacing doubleValue]];
    [paragraphStyle setLineHeightMultiple:[lineHeightMultiple doubleValue]];
    [paragraphStyle setAlignment:lblView.textAlignment];
    [paragraphStyle setLineBreakMode:lblView.lineBreakMode];

    NSMutableAttributedString*  attrString  = [attributedString mutableCopy];

    NSRange attrRange   = NSMakeRange(0, [attrString length]);

    [attrString addAttributes:@{ NSParagraphStyleAttributeName: paragraphStyle }
                        range:attrRange];

    NSMutableArray* savedAttributes = [NSMutableArray array];

    [attrString enumerateAttributesInRange:attrRange
                                   options:0
                                usingBlock:^(NSDictionary *attrs, NSRange range, BOOL* stop)
     {
         DNAttributedStringAttribute*   asa = [[DNAttributedStringAttribute alloc] init];
         asa.attributes = attrs;
         asa.range      = range;

         [savedAttributes addObject:asa];
     }];

    NSAssert(labelKerning, @"%@/%@/%@/%@/Label/Kerning is not specified!", group, screen, viewState, item);
    [attrString removeAttribute:NSKernAttributeName range:attrRange];
    [attrString addAttribute:NSKernAttributeName value:labelKerning range:attrRange];

    NSAssert(labelFont, @"%@/%@/%@/%@/Label/Font is not specified!", group, screen, viewState, item);
    [attrString removeAttribute:NSFontAttributeName range:attrRange];
    [attrString addAttribute:NSFontAttributeName value:labelFont range:attrRange];
    
    NSAssert(labelColor, @"%@/%@/%@/%@/Label/Color is not specified!", group, screen, viewState, item);
    [attrString removeAttribute:NSForegroundColorAttributeName range:attrRange];
    [attrString addAttribute:NSForegroundColorAttributeName value:labelColor range:attrRange];

    [attrString removeAttribute:NSParagraphStyleAttributeName range:attrRange];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attrRange];

    [savedAttributes enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL* stop)
     {
         //DNAttributedStringAttribute*   asa = obj;

         //[attrString addAttributes:asa.attributes range:asa.range];
     }];

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

    lblView.minimumScaleFactor  = [[[self class] performThemeSelectorForAttribute:@"MinimumScaleFactor" withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] doubleValue];

    if ([lblView isKindOfClass:[DNLabel class]])
    {
        ((DNLabel*)lblView).verticalAlignment   = [[[self class] performThemeSelectorForAttribute:@"VerticalAlignment"  withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] intValue];
        //((DNLabel*)lblView).lineHeightMultiple  = [[[self class] performThemeSelectorForAttribute:@"LineHeightMultiple" withType:@"Label" andGroup:group andScreen:screen andViewState:viewState andItem:item] intValue];
    }

    NSAttributedString* attributedString    = [lblView attributedText];
    if ([attributedString length] == 0)
    {
        if ([lblView.text length] > 0)
        {
            attributedString = [[NSMutableAttributedString alloc] initWithString:lblView.text];
        }
    }

    NSAttributedString* attrString  = [[self class] labelAttributedString:lblView
                                                     withAttributedString:attributedString
                                                                  andType:@"Label"
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
        NSAttributedString* attributedString    = [btnView attributedTitleForState:UIControlStateNormal];
        if ([attributedString length] == 0)
        {
            NSString*   string  = [btnView titleForState:UIControlStateNormal];
            if (!string)
            {
                string  = @"";
            }
            attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        }
        
        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                         withAttributedString:attributedString
                                                                      andType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateNormal];
        [btnView setAttributedTitle:attrString forState:UIControlStateNormal];
    }
    {
        NSAttributedString* attributedString    = [btnView attributedTitleForState:UIControlStateHighlighted];
        if ([attributedString length] == 0)
        {
            NSString*   string  = [btnView titleForState:UIControlStateHighlighted];
            if (!string)
            {
                string  = @"";
            }
            attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        }

        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                         withAttributedString:attributedString
                                                                      andType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateHighlighted];
        [btnView setAttributedTitle:attrString forState:UIControlStateHighlighted];
    }
    {
        NSAttributedString* attributedString    = [btnView attributedTitleForState:UIControlStateDisabled];
        if ([attributedString length] == 0)
        {
            NSString*   string  = [btnView titleForState:UIControlStateDisabled];
            if (!string)
            {
                string  = @"";
            }
            attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        }

        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                         withAttributedString:attributedString
                                                                      andType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateDisabled];
        [btnView setAttributedTitle:attrString forState:UIControlStateDisabled];
    }
    {
        NSAttributedString* attributedString    = [btnView attributedTitleForState:UIControlStateSelected];
        if ([attributedString length] == 0)
        {
            NSString*   string  = [btnView titleForState:UIControlStateSelected];
            if (!string)
            {
                string  = @"";
            }
            attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        }

        NSAttributedString* attrString  = [[self class] labelAttributedString:btnView.titleLabel
                                                         withAttributedString:attributedString
                                                                      andType:@"ButtonLabel"
                                                                     andGroup:group
                                                                    andScreen:screen
                                                                 andViewState:viewState
                                                                      andItem:item
                                                              andControlState:UIControlStateSelected];
        [btnView setAttributedTitle:attrString forState:UIControlStateSelected];
    }

    if ([btnView isKindOfClass:[DNButton class]])
    {
        UIColor*    tintColorNormal         = [[self class] performThemeSelectorForAttribute:@"TintColor" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateNormal];
        UIColor*    tintColorHighlighted    = [[self class] performThemeSelectorForAttribute:@"TintColor" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateHighlighted];
        UIColor*    tintColorDisabled       = [[self class] performThemeSelectorForAttribute:@"TintColor" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateDisabled];
        UIColor*    tintColorSelected       = [[self class] performThemeSelectorForAttribute:@"TintColor" withType:@"Button" andGroup:group andScreen:screen andViewState:viewState andItem:item andControlState:UIControlStateSelected];

        DNButton*   dnButton    = (DNButton*)btnView;
        [dnButton setTintColor:tintColorNormal      forState:UIControlStateNormal];
        [dnButton setTintColor:tintColorHighlighted forState:UIControlStateHighlighted];
        [dnButton setTintColor:tintColorDisabled    forState:UIControlStateDisabled];
        [dnButton setTintColor:tintColorSelected    forState:UIControlStateSelected];
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

    txtfldView.textColor            = [[self class] performThemeSelectorForAttribute:@"Color"           withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    txtfldView.font                 = [[self class] performThemeSelectorForAttribute:@"Font"            withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    txtfldView.borderStyle          = [[[self class] performThemeSelectorForAttribute:@"BorderStyle"    withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] integerValue];
    txtfldView.keyboardType         = [[[self class] performThemeSelectorForAttribute:@"KeyboardType"   withType:@"TextField" andGroup:group andScreen:screen andViewState:viewState andItem:item] integerValue];
    
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
        else
        {
            ((DNTextField*)txtfldView).useSyntaxCompletion      = NO;
            ((DNTextField*)txtfldView).useSyntaxHighlighting    = NO;
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

    UIColor*    linkTextColor               = [[self class] performThemeSelectorForAttribute:@"LinkTextColor"               withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    UIFont*     linkTextFont                = [[self class] performThemeSelectorForAttribute:@"LinkTextFont"                withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   linkTextAlignment           = [[self class] performThemeSelectorForAttribute:@"LinkTextAlignment"           withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   linkTextUnderline           = [[self class] performThemeSelectorForAttribute:@"LinkTextUnderline"           withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   linkTextKerning             = [[self class] performThemeSelectorForAttribute:@"LinkTextKerning"             withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   linkTextLineSpacing         = [[self class] performThemeSelectorForAttribute:@"LinkTextLineSpacing"         withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
    NSNumber*   linkTextLineHeightMultiple  = [[self class] performThemeSelectorForAttribute:@"LinkTextLineHeightMultiple"  withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

    NSMutableParagraphStyle*    linkTextParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [linkTextParagraphStyle setAlignment:[linkTextAlignment doubleValue]];
    [linkTextParagraphStyle setLineSpacing:[linkTextLineSpacing doubleValue]];
    [linkTextParagraphStyle setLineHeightMultiple:[linkTextLineHeightMultiple doubleValue]];

    txtView.linkTextAttributes  = @{
                                    NSForegroundColorAttributeName  : linkTextColor,
                                    NSFontAttributeName             : linkTextFont,
                                    NSKernAttributeName             : linkTextKerning,
                                    NSUnderlineStyleAttributeName   : linkTextUnderline,
                                    NSParagraphStyleAttributeName   : linkTextParagraphStyle
                                    };

    if ([txtView isKindOfClass:[DNTextView class]])
    {
        ((DNTextView*)txtView).textColor        = [[self class] performThemeSelectorForAttribute:@"Color"             withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        ((DNTextView*)txtView).placeholderColor = [[self class] performThemeSelectorForAttribute:@"PlaceholderColor"  withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item];

        // Default is YES/nil if not specified, therefore, if != NO...
        if (![[[self class] performThemeSelectorForAttribute:@"ShowSuggestions" withType:@"TextView" andGroup:group andScreen:screen andViewState:viewState andItem:item] isEqual:@NO])
        {
            CGRect  attachmentViewFrame = CGRectMake(0, 0, [DNUtilities screenWidth], 32.0f);
            JTKeyboardAttachmentView*   attachmentView = [[JTKeyboardAttachmentView alloc] initWithFrame:attachmentViewFrame];
            [txtView setInputAccessoryView:attachmentView];
        }
        else
        {
            ((DNTextView*)txtView).useSyntaxCompletion      = NO;
            ((DNTextView*)txtView).useSyntaxHighlighting    = NO;
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

        NSAssert(textAttributesKerning, @"%@/%@/%@/%@/SegmentedControl/Kerning is not specified!", group, screen, viewState, item);
        [textAttributes setObject:textAttributesKerning forKey:NSKernAttributeName];

        NSAssert(textAttributesFont, @"%@/%@/%@/%@/SegmentedControl/Font is not specified!", group, screen, viewState, item);
        [textAttributes setObject:textAttributesFont forKey:NSFontAttributeName];

        NSAssert(textAttributesColor, @"%@/%@/%@/%@/SegmentedControl/Color is not specified!", group, screen, viewState, item);
        [textAttributes setObject:textAttributesColor forKey:NSForegroundColorAttributeName];

        ((DNSegmentedControl*)segmentedControl).textAttributes = textAttributes;

        NSNumber*   selectedTextAttributesKerning   = [[self class] performThemeSelectorForAttribute:@"SelectedKerning" withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        UIFont*     selectedTextAttributesFont      = [[self class] performThemeSelectorForAttribute:@"SelectedFont"    withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];
        UIColor*    selectedTextAttributesColor     = [[self class] performThemeSelectorForAttribute:@"SelectedColor"   withType:@"SegmentedControl" andGroup:group andScreen:screen andViewState:viewState andItem:item];

        NSMutableDictionary*    selectedTextAttributes  = [NSMutableDictionary dictionary];

        NSAssert(selectedTextAttributesKerning, @"%@/%@/%@/%@/SegmentedControl/SelectedKerning is not specified!", group, screen, viewState, item);
        selectedTextAttributes[NSKernAttributeName]             = textAttributesKerning;

        NSAssert(selectedTextAttributesFont, @"%@/%@/%@/%@/SegmentedControl/SelectedFont is not specified!", group, screen, viewState, item);
        selectedTextAttributes[NSFontAttributeName]             = selectedTextAttributesFont;

        NSAssert(selectedTextAttributesColor, @"%@/%@/%@/%@/SegmentedControl/SelectedColor is not specified!", group, screen, viewState, item);
        selectedTextAttributes[NSForegroundColorAttributeName]  = selectedTextAttributesColor;

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

    NSAssert(labelKerning, @"%@/%@/%@/%@/%lu/BarButtonItem/LabelKerning is not specified!", group, screen, viewState, item, controlState);
    textAttributes[NSKernAttributeName]             = labelKerning;

    NSAssert(labelFont, @"%@/%@/%@/%@/%lu/BarButtonItem/LabelFont is not specified!", group, screen, viewState, item, controlState);
    textAttributes[NSFontAttributeName]             = labelFont;

    NSAssert(labelColor, @"%@/%@/%@/%@/%lu/BarButtonItem/LabelColor is not specified!", group, screen, viewState, item, controlState);
    textAttributes[NSForegroundColorAttributeName]  = labelColor;

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
