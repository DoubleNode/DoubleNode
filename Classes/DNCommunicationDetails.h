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
#import <RBRouteBuilder/RBRouteBuilder.h>

typedef NS_ENUM(NSUInteger, DNCommunicationDetailsContentType)
{
    DNCommunicationDetailsContentTypeFormUrlEncoded,
    DNCommunicationDetailsContentTypeJSON,
};

@class DNCommunicationPageDetails;

@interface DNCommunicationDetails : NSObject

@property (strong, nonatomic) NSString*         apikey;
@property (strong, nonatomic) RBRouteBuilder*   router;
@property (strong, nonatomic) NSDictionary*     parameters;
@property (strong, nonatomic) NSDictionary*     files;

@property (assign, nonatomic) NSUInteger        offset;
@property (assign, nonatomic) NSUInteger        count;

@property (assign, nonatomic) DNCommunicationDetailsContentType contentType;

+ (id)details;

- (NSString*)path;
- (NSURL*)URL;

- (NSString*)paramStringWithAllowedCharacterSet:(NSCharacterSet*)allowedCharacterSet;

- (NSString*)fullPathOfPage:(DNCommunicationPageDetails*)pageDetails;
- (NSString*)pagingStringOfSize:(NSUInteger)pageSize
                        andPage:(NSUInteger)page;

- (BOOL)enumeratePagesOfSize:(NSUInteger)pageSize
                  usingBlock:(BOOL (^)(DNCommunicationPageDetails* pageDetails, NSString* fullpath, BOOL* stop))block;

@end
