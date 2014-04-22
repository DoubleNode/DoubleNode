//
//  DNCommunicationDetails.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RBRouteBuilder.h"

@interface DNCommunicationDetails : NSObject

@property (strong, nonatomic) NSString*         apikey;
@property (strong, nonatomic) RBRouteBuilder*   router;
@property (strong, nonatomic) NSDictionary*     parameters;
@property (assign, nonatomic) NSUInteger        offset;
@property (assign, nonatomic) NSUInteger        count;

+ (id)details;

- (NSString*)path;
- (NSURL*)URL;

@end
