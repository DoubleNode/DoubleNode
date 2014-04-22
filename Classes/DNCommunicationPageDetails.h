//
//  DNCommunicationPageDetails.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNCommunicationPageDetails : NSObject

@property (assign, nonatomic) NSUInteger    pageSize;
@property (assign, nonatomic) NSUInteger    page;

+ (id)pageDetails;
+ (id)pageDetailsOfSize:(NSUInteger)pageSize
                andPage:(NSUInteger)page;

- (id)initWithSize:(NSUInteger)pageSize
           andPage:(NSUInteger)page;

- (NSString*)paramString;
- (NSString*)pagingStringOfSize:(NSUInteger)pageSize
                        andPage:(NSUInteger)page;

@end
