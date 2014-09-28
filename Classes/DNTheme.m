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

@property (strong, nonatomic) NSCache*  cache;

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

    // Init the memory cache
    self.cache      = [[NSCache alloc] init];
    self.cache.name = @"com.doublenode.dntheme.cache";
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Init the memory cache
        self.cache      = [[NSCache alloc] init];
        self.cache.name = @"com.doublenode.dntheme.cache";
    }

    return self;
}

- (UIFont*)Font {   return [UIFont systemFontOfSize:[UIFont systemFontSize]];   }

- (NSNumber*)LabelKerning   {   return @1.0f;   }

- (UIColor*)BorderColor     {   return nil;     }
- (NSNumber*)BorderWidth    {   return @0.0f;   }

- (void)saveCacheObject:(NSString*)functionName
                 forKey:(NSString*)cacheKey
{
    //[self.cache setObject:functionName forKey:cacheKey cost:[functionName length]];
}

- (SEL)functionNameForAttribute:(NSString*)attribute
                       withType:(NSString*)type
                       andGroup:(NSString*)group
                      andScreen:(NSString*)screen
                   andViewState:(NSString*)viewState
                        andItem:(NSString*)item
                andControlState:(NSString*)controlStateString
{
    SEL functionSelector;
    
    NSString*   cacheKey        = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", group, screen, viewState, item, type, attribute, controlStateString];
    NSString*   functionName    = [self.cache objectForKey:cacheKey];
    if (functionName)
    {
        if ([functionName isEqualToString:@""])
        {
            return nil;
        }

        functionSelector    = NSSelectorFromString(functionName);
        return functionSelector;
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font Normal
    functionName        = cacheKey;
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];

        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG WelcomeView SignIn Button Font Normal
    functionName        = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, item, type, attribute, controlStateString];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG WelcomeView SignInWithKeyboard SignIn Button Font
    functionName        = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, item, type, attribute];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG WelcomeView SignIn Button Font
    functionName        = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, item, type, attribute];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG WelcomeView SignInWithKeyboard Button Font Normal
    functionName        = [NSString stringWithFormat:@"%@%@%@%@%@%@", group, screen, viewState, type, attribute, controlStateString];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG WelcomeView SignInWithKeyboard Button Font
    functionName        = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, viewState, type, attribute];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG WelcomeView Button Font Normal
    functionName        = [NSString stringWithFormat:@"%@%@%@%@%@", group, screen, type, attribute, controlStateString];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG WelcomeView Button Font
    functionName        = [NSString stringWithFormat:@"%@%@%@%@", group, screen, type, attribute];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG Button Font Normal
    functionName        = [NSString stringWithFormat:@"%@%@%@%@", group, type, attribute, controlStateString];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // LOG Button Font
    functionName        = [NSString stringWithFormat:@"%@%@%@", group, type, attribute];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // Button Font Normal
    functionName        = [NSString stringWithFormat:@"%@%@%@", type, attribute, controlStateString];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // Button Font
    functionName        = [NSString stringWithFormat:@"%@%@", type, attribute];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    // Font
    functionName        = [NSString stringWithFormat:@"%@", attribute];
    functionSelector    = NSSelectorFromString(functionName);
    if ([self respondsToSelector:functionSelector] == YES)
    {
        [self saveCacheObject:functionName forKey:cacheKey];
        
        //DLog(LL_Debug, LD_Theming, @"Calling %@...", functionName);
        return functionSelector;
    }

    functionName    = @"";
    [self saveCacheObject:functionName forKey:cacheKey];

    //DLog(LL_Debug, LD_Theming, @"No Function Called!");
    return nil;
}

@end
