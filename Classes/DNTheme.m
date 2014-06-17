//
//  DNTheme.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNTheme.h"

#import "UIFont+Custom.h"

@interface DNTheme ()

@property (strong, nonatomic) NSMutableDictionary*  cacheDictionary;

@end

@implementation DNTheme

@synthesize primaryColor    = _primaryColor;
@synthesize secondaryColor  = _secondaryColor;

- (UIColor*)defaultPrimaryColor
{
    return [UIColor darkGrayColor];
}

- (UIColor*)defaultSecondaryColor
{
    return [UIColor lightGrayColor];
}

- (UIColor*)primaryColor
{
    if (!_primaryColor)
    {
        _primaryColor   = [self defaultPrimaryColor];
    }

    return _primaryColor;
}

- (UIColor*)secondaryColor
{
    if (!_secondaryColor)
    {
        _secondaryColor = [self defaultSecondaryColor];
    }

    return _secondaryColor;
}

- (void)resetCache
{
    _primaryColor   = nil;
    _secondaryColor = nil;

    self.cacheDictionary    = [[NSMutableDictionary alloc] init];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.cacheDictionary    = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (UIFont*)Font {   return [UIFont systemFontOfSize:[UIFont systemFontSize]];   }

- (NSNumber*)LabelKerning   {   return @1.0f;   }

- (UIColor*)BorderColor     {   return nil;     }
- (NSNumber*)BorderWidth    {   return @0.0f;   }

- (SEL)functionNameForAttribute:(NSString*)attribute
                       withType:(NSString*)type
                       andGroup:(NSString*)group
                      andScreen:(NSString*)screen
                   andViewState:(NSString*)viewState
                        andItem:(NSString*)item
                andControlState:(NSString*)controlStateString
{
    NSString*   cacheKey        = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];

    NSString*   functionName    = [self.cacheDictionary objectForKey:cacheKey];
    if (functionName)
    {
        if ([functionName isEqualToString:@""])
        {
            return nil;
        }

        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignIn Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, item, type, attribute, controlStateString];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, item, type, attribute];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignIn Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, item, type, attribute];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, type, attribute, controlStateString];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView SignInWithKeyboard Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, viewState, type, attribute];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, type, attribute, controlStateString];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG WelcomeView Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@%@", group, screen, type, attribute];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@%@", group, type, attribute, controlStateString];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // LOG Button Font
    functionName  = [NSString stringWithFormat:@"%@%@%@", group, type, attribute];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // Button Font Normal
    functionName  = [NSString stringWithFormat:@"%@%@%@", type, attribute, controlStateString];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // Button Font
    functionName  = [NSString stringWithFormat:@"%@%@", type, attribute];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    // Font
    functionName  = [NSString stringWithFormat:@"%@", attribute];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        self.cacheDictionary[cacheKey]  = functionName;

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return NSSelectorFromString(functionName);
    }

    self.cacheDictionary[cacheKey]  = @"";

    //DLog(LL_Debug, LD_Theming, @"No Function Called!");
    return nil;
}

@end
