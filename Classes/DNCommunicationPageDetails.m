//
//  DNCommunicationPageDetails.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNCommunicationPageDetails.h"

@implementation DNCommunicationPageDetails

+ (id)pageDetails
{
    return [[[self class] alloc] init];
}

+ (id)pageDetailsOfSize:(NSUInteger)pageSize
                andPage:(NSUInteger)page
{
    return [[[self class] alloc] initWithSize:pageSize andPage:page];
}

- (id)initWithSize:(NSUInteger)pageSize
           andPage:(NSUInteger)page
{
    self = [self init];
    if (self)
    {
        self.pageSize   = pageSize;
        self.page       = page;
    }

    return self;
}

- (NSString*)paramString
{
    return [self pagingStringOfSize:self.pageSize andPage:self.page];
}

- (NSString*)pagingStringOfSize:(NSUInteger)pageSize
                        andPage:(NSUInteger)page
{
    return [NSString stringWithFormat:@"items_per_page=%lu&page=%lu", (unsigned long)pageSize, (unsigned long)page];
}

@end
