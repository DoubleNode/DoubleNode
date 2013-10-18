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

+ (UIColor*)colorWithString:(NSString*)string
{
    return [UIColor colorWithString:[[self class] constantValue:string]];
}

+ (BOOL)boolWithString:(NSString*)string
{
    return [[[self class] constantValue:string] boolValue];
}

+ (double)doubleWithPreString:(NSString*)string
{
    return [[[self class] constantValue:string] doubleValue];
}

+ (UIFont*)fontWithPreString:(NSString*)preString
{
    NSString*   fontName    = [[self class] constantValue:[NSString stringWithFormat:@"%@Name", preString]];
    NSString*   fontSize    = [[self class] constantValue:[NSString stringWithFormat:@"%@Size", preString]];
    
    UIFont* retFont  = [UIFont fontWithName:fontName size:([fontSize doubleValue] / 2)];
    
    return [retFont fontWithSize:([fontSize doubleValue] / 2)];
}

+ (CGSize)sizeWithPreString:(NSString*)preString
{
    NSString*   sizeWidth   = [[self class] constantValue:[NSString stringWithFormat:@"%@Width", preString]];
    NSString*   sizeHeight  = [[self class] constantValue:[NSString stringWithFormat:@"%@Height", preString]];
    
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
        DLog(LL_Warning, LD_CoreFramework, @"***** MISSING CONSTANT KEY: %@", key);
    }
    
    return value;
}

@end
