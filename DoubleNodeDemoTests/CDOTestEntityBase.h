//
//  CDOTestEntityBase.h
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "DNManagedObject.h"

#import "Foundry.h"

@interface CDOTestEntityBase : DNManagedObject<TGFoundryObject>

@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSDate*   added;

+ (instancetype)foundryBuildWithContext:(NSManagedObjectContext*)context;

@end
