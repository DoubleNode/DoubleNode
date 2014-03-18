//
//  DNAppConstants.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNAppConstants.h"

#import "ColorUtils.h"
#import "DNUtilities.h"

@implementation DNAppConstants

+ (NSString*)oAuthCredentialIdentifier
{
    return [[self class] constantValue:@"oAuthCredentialIdentifier"];
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

+ (NSDictionary*)plistDict
{
    @synchronized( self )
    {
        if (plistConfigDict == nil)
        {
            plistConfigDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Constants_plist"] ofType:@"plist"]];
        }
    }
    
    return plistConfigDict;
}

+ (id)plistConfig:(NSString*)key
{
    NSDictionary*   dict = [[self class] plistDict];
    
    id  value = [dict objectForKey:key];
    if ((value == nil) || (value == [NSNull null]))
    {
        DLog(LL_Warning, LD_Framework, @"***** MISSING CONSTANT KEY: %@", key);
    }
    
    return value;
}

@end
