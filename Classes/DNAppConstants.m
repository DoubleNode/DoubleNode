//
//  DNAppConstants.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNAppConstants.h"

#import "ColorUtils.h"
#import "DNUtilities.h"

@implementation DNAppConstants

+ (NSString*)oAuthCredentialIdentifier
{
    return [[self class] constantValue:@"oAuthCredentialIdentifier"];
}

+ (NSString*)apiHostname
{
    return [[self class] constantValue:@"apiHostname"];
}

+ (UIColor*)colorConstant:(NSString*)key
{
    return [UIColor colorWithString:[[self class] constantValue:key]];
}

+ (BOOL)boolConstant:(NSString*)key
{
    return [[[self class] constantValue:key] boolValue];
}

+ (double)doubleConstant:(NSString*)key
{
    return [[[self class] constantValue:key] doubleValue];
}

+ (int)intConstant:(NSString*)key
{
    return [[[self class] constantValue:key] intValue];
}

+ (UIFont*)fontConstant:(NSString*)key
{
    NSString*   fontName    = [[self class] constantValue:[NSString stringWithFormat:@"%@Name", key]];
    NSString*   fontSize    = [[self class] constantValue:[NSString stringWithFormat:@"%@Size", key]];
    
    UIFont* retFont  = [UIFont fontWithName:fontName size:([fontSize doubleValue] / 2)];
    
    return [retFont fontWithSize:([fontSize doubleValue] / 2)];
}

+ (CGSize)sizeConstant:(NSString*)key
{
    NSString*   sizeWidth   = [[self class] constantValue:[NSString stringWithFormat:@"%@Width", key]];
    NSString*   sizeHeight  = [[self class] constantValue:[NSString stringWithFormat:@"%@Height", key]];
    
    return CGSizeMake([sizeWidth floatValue], [sizeHeight floatValue]);
}

+ (id)constantValue:(NSString*)key
{
    NSString*   value   = [NSString stringWithFormat:@"%@", [[self class] plistConfig:key]];
    
    return value;
}

static NSDictionary*    plistConfigDict = nil;
static NSString*        plistServerCode = nil;

+ (NSDictionary*)plistDict
{
    NSString*   serverCode  = [[DNUtilities appDelegate] settingsItem:@"ServerCode"];
    //DLog(LL_Debug, LD_General, @"ServerCode=%@", serverCode);
    if (![serverCode isEqualToString:plistServerCode])
    {
        plistConfigDict = nil;
        plistServerCode = serverCode;
    }

    @synchronized( self )
    {
        if (plistConfigDict == nil)
        {
            NSString*   constantsPlist  = [NSString stringWithFormat:@"Constants_%@", serverCode];
            NSString*   constantsPath   = [[NSBundle mainBundle] pathForResource:constantsPlist ofType:@"plist"];
            if (!constantsPath)
            {
                NSException*    exception = [NSException exceptionWithName:@"DNAppConstants Exception"
                                                                    reason:[NSString stringWithFormat:@"Constants plist not found: %@", constantsPlist]
                                                                  userInfo:nil];
                @throw exception;
            }

            plistConfigDict = [[NSDictionary alloc] initWithContentsOfFile:constantsPath];
            if (!plistConfigDict)
            {
                NSException*    exception = [NSException exceptionWithName:@"DNAppConstants Exception"
                                                                    reason:[NSString stringWithFormat:@"Unable to initialize Constants Config Dictionary: %@", constantsPath]
                                                                  userInfo:nil];
                @throw exception;
            }
        }
    }
    
    return plistConfigDict;
}

+ (id)plistConfig:(NSString*)key
{
    NSDictionary*   dict = [[self class] plistDict];
    
    id  value = dict[key];
    if ((value == nil) || (value == [NSNull null]))
    {
        DLog(LL_Warning, LD_Framework, @"***** MISSING CONSTANT KEY: %@", key);
    }
    
    return value;
}

@end
