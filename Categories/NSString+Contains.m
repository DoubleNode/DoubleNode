//
//  NSString+Contains.m
//  Pods
//
//  Created by Darren Ehlers on 2/27/14.
//
//

#import "NSString+Contains.h"

@implementation NSString (Contains)

- (BOOL)contains:(NSString*)subString
{
    return ([self rangeOfString:subString].location != NSNotFound);
}

@end
