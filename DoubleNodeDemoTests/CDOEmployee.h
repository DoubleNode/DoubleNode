//
//  CDOEmployee.h
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "CDOTestEntityBase.h"

@class CDOCompany;

@interface CDOEmployee : CDOTestEntityBase
CDO_DEFAULT_METHOD_PROTOTYPES(employee, Employee)

@property (nonatomic, retain) NSDate*   birthdate;
@property (nonatomic, retain) NSString* firstName;
@property (nonatomic, retain) NSString* lastName;

@property (nonatomic, retain) CDOCompany*   company;

@end
