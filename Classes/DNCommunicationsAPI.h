//
//  DNCommunicationsAPI.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNCommunicationDetails.h"

#import "DNUtilities.h"

typedef BOOL(^APIProcessingNowBlock)(NSArray* objects);

@interface DNCommunicationsAPIQueued : NSObject

@property (nonatomic, copy) BOOL    (^filterHandler)(id item);
@property (nonatomic, copy) void    (^completionHandler)(DNCommunicationDetails* commDetails, NSArray* items);
@property (nonatomic, copy) void    (^errorHandler)(DNCommunicationDetails* commDetails, NSError* error, NSTimeInterval retryRecommendation);

@end

@interface DNCommunicationsAPI : NSObject

+ (id)manager;

- (id)init;

- (NSURLRequest*)addAuthorizationHeader:(NSURLRequest*)request;

- (void)reauthorizeWithSuccess:(void (^)(void))success
                       failure:(void (^)(void))failure;

- (BOOL)isExpired:(NSString*)cacheKey
          withTTL:(NSUInteger)ttl;

- (void)markAPIKeyUpdated:(NSString*)apikey;

- (void)markAPIKeyUpdated:(NSString*)apikey
                   withID:(id)idValue;

- (void)markAPIKeyUpdated:(NSString*)apikey
                   withID:(id)idValue
          withParamString:(NSString*)params;

- (void)markAPIKeyExpired:(NSString*)apikey;

- (void)markAPIKeyExpired:(NSString*)apikey
                   withID:(id)idValue;

- (void)markAPIKeyExpired:(NSString*)apikey
                   withID:(id)idValue
          withParamString:(NSString*)params;

- (void)markUpdated:(NSString*)cacheKey;
- (void)markExpired:(NSString*)cacheKey;

- (NSString*)getAPIHostname;
- (NSString*)getAPIHostnameString;
- (NSString*)getFirstPartMethod:(NSString*)methodName;

- (NSString*)apiURLRetrieve:(NSString*)apikey;
- (NSInteger)apiPageSizeRetrieve:(NSString*)apikey;
- (NSInteger)apiPageSizeRetrieve:(NSString*)apikey
                         default:(NSInteger)defaultPageSize;
- (NSInteger)apiTTLRetrieve:(NSString*)apikey;
- (NSInteger)apiTTLRetrieve:(NSString*)apikey
                    default:(NSInteger)defaultTTL;
- (void)resetRetryRecommendation:(NSString*)apikey;
- (NSTimeInterval)retryRecommendation:(NSString*)apikey;

- (BOOL)processNow:(DNCommunicationDetails*)commDetails
           objects:(NSArray*)objects
            filter:(BOOL(^)(id object))filterHandler
               now:(void(^)(NSArray* objects, BOOL isExpired))nowHandler;

- (void)processRequest:(DNCommunicationDetails*)commDetails
            completion:(void(^)(DNCommunicationDetails* commDetails, NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(DNCommunicationDetails* commDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation))errorHandler;

/*
- (void)processPut:(NSString*)apikey
        withRouter:(id)router
            withID:(id)idValue
        withParams:(NSDictionary*)params
        completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
             error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processPut:(NSString*)apikey
        withRouter:(id)router
            withID:(id)idValue
        withParams:(NSDictionary*)params
         withFiles:(NSArray*)files
        completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
             error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processPost:(NSString*)apikey
         withRouter:(id)router
         withParams:(NSDictionary*)params
         completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processPost:(NSString*)apikey
         withRouter:(id)router
             withID:(id)idValue
         withParams:(NSDictionary*)params
         completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processPost:(NSString*)apikey
         withRouter:(id)router
         withParams:(NSDictionary*)params
          withFiles:(NSArray*)files
         completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

 - (void)processRequest:(NSString*)apikey
            withRouter:(id)router
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processRequest:(NSString*)apikey
            withRouter:(id)router
                withID:(id)idValue
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processRequest:(NSString*)apikey
            withRouter:(id)router
       withParamString:(NSString*)params
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processRequest:(NSString*)apikey
            withRouter:(id)router
                withID:(id)idValue
       withParamString:(NSString*)params
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;
*/

- (void)subProcessResponse:(NSHTTPURLResponse*)httpResponse
               commDetails:(DNCommunicationDetails*)commDetails
                 errorCode:(NSInteger)errorCode
                   request:(NSURLRequest*)request
                      data:(NSData*)data
                     retry:(void(^)(DNCommunicationDetails* commDetails))retryHandler
                completion:(void(^)(DNCommunicationDetails* commDetails, NSDictionary* response, NSDictionary* headers))completionHandler
                     error:(void(^)(DNCommunicationDetails* commDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation))errorHandler;

- (void)subProcessRequest:(NSURLRequest*)request
              commDetails:(DNCommunicationDetails*)commDetails
               completion:(void(^)(DNCommunicationDetails* commDetails, NSDictionary* response, NSDictionary* headers))completionHandler
                    error:(void(^)(DNCommunicationDetails* commDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation))errorHandler;

- (BOOL)queueProcess:(DNCommunicationDetails*)commDetails
              filter:(BOOL(^)(id object))filterHandler
          completion:(void(^)(DNCommunicationDetails* commDetails, NSArray* objects))completionHandler
               error:(void(^)(DNCommunicationDetails* commDetails, NSError* error, NSTimeInterval retryRecommendation))errorHandler;

/*
- (void)processingCompletionBlock:(NSString*)apikey
                       withRouter:(id)router
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filterHandler
                       completion:(void(^)(NSArray* speakers))completionHandler;

- (void)processingCompletionBlock:(NSString*)apikey
                       withRouter:(id)router
                           withID:(id)idValue
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filterHandler
                       completion:(void(^)(NSArray* speakers))completionHandler;

- (void)processingCompletionBlock:(NSString*)apikey
                       withRouter:(id)router
                           withID:(id)idValue
                  withParamString:(NSString*)params
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filterHandler
                       completion:(void(^)(NSArray* speakers))completionHandler;

- (void)processingQueueCompletionBlock:(NSString*)apikey
                            withRouter:(id)router
                               objects:(NSArray*)objects;

- (void)processingQueueErrorBlock:(NSString*)apikey
                       withRouter:(id)router
                     responseCode:(NSInteger)responseCode
                            error:(NSError*)error
                              url:(NSString*)url
              retryRecommendation:(NSTimeInterval)retryRecommendation;
*/

@end
