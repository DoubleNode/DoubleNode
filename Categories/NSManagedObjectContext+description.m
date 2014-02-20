//
//  NSManagedObjectContext+description.m
//  Phoenix
//
//  Created by Darren Ehlers on 2/19/14.
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//

#import "NSManagedObjectContext+description.h"

@implementation NSManagedObjectContext (description)

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%@>", NSStringFromClass([self class]), [self.userInfo objectForKey:@"mocName"]];
}

@end
