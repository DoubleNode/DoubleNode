//
//  CDCompanyModel.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "CDCompanyModel.h"

#import "CDTestDataModel.h"

#import "CDOCompany.h"

@interface CDCompanyModel ()

@end

@implementation CDCompanyModel

+ (NSString*)dataModelName
{
    return @"Test";
}

+ (Class)dataModelClass
{
    return [CDTestDataModel class];
}

@end
