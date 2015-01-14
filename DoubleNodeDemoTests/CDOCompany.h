//
//  CDOCompany.h
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "CDOTestEntityBase.h"

@class CDOEmployee;

@interface CDOCompany : CDOTestEntityBase
CDO_DEFAULT_METHOD_PROTOTYPES(company, Company)

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSSet*    employees;

@end

@interface CDOCompany (CoreDataGeneratedAccessors)

CDO_TOMANY_ACCESSORS_PROTOTYPES(Employees, Employee)

@end
