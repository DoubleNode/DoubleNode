//
//  NSDate+PrettyDate.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "NSDate+PrettyDate.h"

@implementation NSDate (PrettyDate)

- (NSString*)shortPrettyDate
{
    NSString*   prettyTimestamp;

    float   delta = [self timeIntervalSinceNow] * -1;
    if (delta < 60)
    {
        prettyTimestamp = @"just now";
        //prettyTimestamp = [NSString stringWithFormat:@"%d seconds ago", (int)delta];
    }
    else if (delta < 120)
    {
        prettyTimestamp = @"1 min ago";
    }
    else if (delta < 3600)
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d mins ago", (int)floor(delta / 60.0f)];
    }
    else if (delta < 7200)
    {
        prettyTimestamp = @"1 hr ago";
    }
    else if (delta < 86400)
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d hrs ago", (int)floor(delta / 3600.0f)];
    }
    else if (delta < (86400 * 2))
    {
        prettyTimestamp = @"1 day ago";
    }
    else if (delta < (86400 * 7))
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d days ago", (int)floor(delta / 86400.0f)];
    }
    else if (delta < (86400 * 14))
    {
        prettyTimestamp = [NSString stringWithFormat:@"1 wk ago"];
    }
    else if (delta < (86400 * 35))
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d wks ago", (int)floor(delta / (86400.0f * 7))];
    }
    else
    {
        NSDateFormatter*    formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];

        prettyTimestamp = [NSString stringWithFormat:@"on %@", [formatter stringFromDate:self]];
    }

    return prettyTimestamp;
}

- (NSString*)prettyDate
{
    NSString*   prettyTimestamp;
    
    float   delta = [self timeIntervalSinceNow] * -1;
    if (delta < 60)
    {
        prettyTimestamp = @"just now";
        //prettyTimestamp = [NSString stringWithFormat:@"%d seconds ago", (int)delta];
    }
    else if (delta < 120)
    {
        prettyTimestamp = @"one minute ago";
    }
    else if (delta < 3600)
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d minutes ago", (int)floor(delta / 60.0f)];
    }
    else if (delta < 7200)
    {
        prettyTimestamp = @"one hour ago";
    }
    else if (delta < 86400)
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d hours ago", (int)floor(delta / 3600.0f)];
    }
    else if (delta < (86400 * 2))
    {
        prettyTimestamp = @"one day ago";
    }
    else if (delta < (86400 * 7))
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d days ago", (int)floor(delta / 86400.0f)];
    }
    else if (delta < (86400 * 14))
    {
        prettyTimestamp = [NSString stringWithFormat:@"one week ago"];
    }
    else if (delta < (86400 * 35))
    {
        prettyTimestamp = [NSString stringWithFormat:@"%d weeks ago", (int)floor(delta / (86400.0f * 7))];
    }
    else
    {
        NSDateFormatter*    formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        prettyTimestamp = [NSString stringWithFormat:@"on %@", [formatter stringFromDate:self]];
    }
    
    return prettyTimestamp;
}

- (NSString*)simpleDateRange:(NSDate*)end
{
    NSString*    startFormat    = [NSDateFormatter dateFormatFromTemplate:@"MMM d"
                                                                  options:0
                                                                   locale:[NSLocale currentLocale]];
    
    NSString*    endFormat      = [NSDateFormatter dateFormatFromTemplate:@"d, yyyy"
                                                                  options:0
                                                                   locale:[NSLocale currentLocale]];

    NSDateFormatter*    startFormatter = [[NSDateFormatter alloc] init];
    [startFormatter setDateFormat:startFormat];

    NSString*   startStr    = [startFormatter stringFromDate:self];
    
    NSDateFormatter*    endFormatter    = [[NSDateFormatter alloc] init];
    [endFormatter setDateFormat:endFormat];
    
    NSString*   endStr  = [endFormatter stringFromDate:end];
    
    return [NSString stringWithFormat:@"%@-%@", startStr, endStr];
}

- (NSString*)localizedDate
{
    NSString*   datestr = [NSDateFormatter localizedStringFromDate:self
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterNoStyle];
    if ([datestr isEqualToString:@"(null)"] == YES)
    {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%@", datestr];
}

@end
