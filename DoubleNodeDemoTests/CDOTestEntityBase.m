//
//  CDOTestEntityBase.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "CDOTestEntityBase.h"

@implementation CDOTestEntityBase

@dynamic id;

+ (instancetype)foundryBuildWithContext:(NSManagedObjectContext*)context
{
    id  entity  = [super foundryBuildWithContext:context];
    
    return entity;
}

+ (NSDictionary*)foundryBuildSpecs
{
    return @{
             @"id"  : @(FoundryPropertyTypeUUID),
             };
}

+ (id)foundryAttributeForProperty:(NSString*)property
{
    return nil;
}

@end
