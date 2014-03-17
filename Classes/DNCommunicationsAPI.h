//
//  DNCommunicationsAPI.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNUtilities.h"

typedef BOOL(^APIProcessingNowBlock)(NSArray* objects);

@interface DNCommunicationsAPIQueued : NSObject

@property (nonatomic, copy) BOOL    (^filter)(id item);
@property (nonatomic, copy) void    (^completionHandler)(NSArray* items);
@property (nonatomic, copy) void    (^errorHandler)(NSError* error, NSString* url, NSTimeInterval retryRecommendation);

@end

@interface DNCommunicationsAPI : NSObject

+ (id)manager;

- (id)init;

- (BOOL)isExpired:(NSString*)cacheKey
          withTTL:(NSUInteger)ttl;

- (void)markAPIKeyUpdated:(NSString*)apikey;
- (void)markUpdated:(NSString*)cacheKey;
- (void)markExpired:(NSString*)cacheKey;

- (NSString*)getAPIHostname;
- (NSString*)getAPIHostnameString;
- (NSString*)getFirstPartMethod:(NSString*)methodName;

- (NSString*)apiURLRetrieve:(NSString*)apikey;
- (NSInteger)apiTTLRetrieve:(NSString*)apikey;
- (NSInteger)apiTTLRetrieve:(NSString*)apikey
                    default:(NSInteger)defaultTTL;
- (void)resetRetryRecommendation:(NSString*)apikey;
- (NSTimeInterval)retryRecommendation:(NSString*)apikey;

- (void)processPut:(NSString*)apikey
            withID:(NSNumber*)idValue
        withParams:(NSDictionary*)params
        completion:(void(^)(NSDictionary* response))completionHandler
             error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processPut:(NSString*)apikey
            withID:(NSNumber*)idValue
        withParams:(NSDictionary*)params
         withFiles:(NSArray*)files
        completion:(void(^)(NSDictionary* response))completionHandler
             error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processPost:(NSString*)apikey
         withParams:(NSDictionary*)params
         completion:(void(^)(NSDictionary* response))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processPost:(NSString*)apikey
         withParams:(NSDictionary*)params
          withFiles:(NSArray*)files
         completion:(void(^)(NSDictionary* response))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processRequest:(NSString*)apikey
            completion:(void(^)(NSDictionary* response))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processRequest:(NSString*)apikey
       withParamString:(NSString*)paramString
            completion:(void(^)(NSDictionary* response))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (BOOL)processingNowBlock:(NSString*)apikey
                   objects:(NSArray*)objects
                    filter:(BOOL(^)(id object))filter
                       now:(void(^)(NSArray* speakers, BOOL isExpired))nowHandler;

- (BOOL)queueProcess:(NSString*)apikey
              filter:(BOOL(^)(id object))filter
          completion:(void(^)(NSArray* speakers))completionHandler
               error:(void(^)(NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler;

- (void)processingCompletionBlock:(NSString*)apikey
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filter
                       completion:(void(^)(NSArray* speakers))completionHandler;

- (void)processingQueueCompletionBlock:(NSString*)apikey
                               objects:(NSArray*)objects;

- (void)processingQueueErrorBlock:(NSString*)apikey
                     responseCode:(NSInteger)responseCode
                            error:(NSError*)error
                              url:(NSString*)url
              retryRecommendation:(NSTimeInterval)retryRecommendation;

@end
