//
//  NSDate+PrettyDate.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "NSDate+PrettyDate.h"

@implementation NSDate (PrettyDate)

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
