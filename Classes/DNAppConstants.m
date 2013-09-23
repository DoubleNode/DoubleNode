//
//  DNAppConstants.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNAppConstants.h"
#import "ColorUtils.h"

#import "CDOConstant.h"

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
    static BOOL firstTime = YES;
    
    @synchronized( self )
    {
        if (firstTime == YES)
        {
            BOOL    resetFlag   = [[[self class] plistConfig:@"ResetConstants"] boolValue];
            if (resetFlag == YES)
            {
                [CDOConstant deleteAll];
            }
            
            //[[PARParleyAPI manager] expireAppStyle];
            
            firstTime = NO;
        }
    }
    
    CDOConstant*    constant = [CDOConstant getFromKey:key];
    if (constant == nil)
    {
        constant        = [[CDOConstant alloc] init];
        constant.key    = key;
        constant.value  = [NSString stringWithFormat:@"%@", [[self class] plistConfig:key]];
        [constant save];
    }
    
    return constant.value;
}

+ (id)plistConfig:(NSString*)key
{
    static NSDictionary*    dict = nil;
    
    @synchronized( self )
    {
        if (dict == nil)
        {
            dict    = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Constants_plist"] ofType:@"plist"]];
        }
    }
    
    id  value = [dict objectForKey:key];
    if ((value == nil) || (value == [NSNull null]))
    {
        NSLog(@"***** MISSING CONSTANT KEY: %@", key);
    }
    
    return value;
}

@end
