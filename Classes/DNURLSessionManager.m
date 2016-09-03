//
//  DNURLSessionManager.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DoubleNode/DNUtilities.h>

#import "DNURLSessionManager.h"

@implementation DNURLSessionManager

+ (_Nonnull instancetype)manager
{
    return [[DNURLSessionManager alloc] init];
}

+ (_Nonnull instancetype)managerWithSessionConfiguration:(NSURLSessionConfiguration* _Nonnull)configuration
{
    return [[DNURLSessionManager alloc] initWithSessionConfiguration:configuration];
}

- (_Nonnull instancetype)init
{
    return [super initWithSessionConfiguration:nil];
}

- (_Nonnull instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration* _Nullable)configuration
{
    if (!configuration)
    {
        configuration   = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    return [super initWithSessionConfiguration:configuration];
}

- (NSURLSessionDataTask*)sendTaskWithRequest:(NSURLRequest*)request
                          serverErrorHandler:(void(^ _Nullable)(NSHTTPURLResponse* _Nullable httpResponse))serverErrorHandler
                            dataErrorHandler:(void(^ _Nullable)(NSData* _Nullable errorData, NSString* _Nullable errorMessage))dataErrorHandler
                         unknownErrorHandler:(void(^ _Nullable)(NSError* _Nullable dataError))unknownErrorHandler
                       noResponseBodyHandler:(void(^ _Nullable)())noResponseBodyHandler
                           completionHandler:(void(^ _Nullable)(NSURLResponse* _Nonnull response, id _Nullable responseObject))completionHandler
{
    return [super dataTaskWithRequest:request
                    completionHandler:
            ^(NSURLResponse* _Nonnull response, id _Nullable responseObject, NSError* _Nullable dataError)
            {
                if (dataError)
                {
                    DLog(LL_Info, LD_Networking, @"DATAERROR - %@", response.URL);
                    
                    if (dataError.code == NSURLErrorTimedOut)
                    {
                        NSHTTPURLResponse*  httpResponse;
                        if ([response isKindOfClass:[NSHTTPURLResponse class]])
                        {
                            httpResponse    = (NSHTTPURLResponse*)response;
                        }
                        
                        DLog(LL_Info, LD_Networking, @"WILLRETRY - %@", response.URL);
                        [DNUtilities runOnBackgroundThreadAfterDelay:1.0f
                                                               block:
                         ^()
                         {
                             serverErrorHandler ? serverErrorHandler(httpResponse) : nil;
                         }];
                        return;
                    }
                    
                    if ([response isKindOfClass:[NSHTTPURLResponse class]])
                    {
                        NSHTTPURLResponse*    httpResponse    = (NSHTTPURLResponse*)response;
                        if (httpResponse.statusCode == 500)
                        {
                            DLog(LL_Info, LD_Networking, @"WILLRETRY - %@", response.URL);
                            [DNUtilities runOnBackgroundThreadAfterDelay:1.0f
                                                                   block:
                             ^()
                             {
                                 serverErrorHandler ? serverErrorHandler(httpResponse) : nil;
                             }];
                            return;
                        }
                    }
                    
                    NSData*    errorData   = dataError.userInfo[@"com.alamofire.serialization.response.error.data"];
                    NSString*  errorString = [[NSString alloc] initWithData:errorData
                                                                   encoding:NSASCIIStringEncoding];
                    DLog(LL_Debug, LD_General, @"data=%@", errorString);
                    
                    if (errorData)
                    {
                        id jsonData = [NSJSONSerialization JSONObjectWithData:errorData
                                                                      options:0
                                                                        error:nil];
                        if (jsonData)
                        {
                            NSString*  errorMessage    = jsonData[@"error"];
                            if (!errorMessage)
                            {
                                errorMessage    = jsonData[@"data"][@"error"];
                            }
                            if (!errorMessage)
                            {
                                errorMessage    = jsonData[@"data"][@"message"];
                            }
                            if (!errorMessage)
                            {
                                errorMessage    = jsonData[@"message"];
                            }
                            
                            dataErrorHandler ? dataErrorHandler(errorData, errorMessage) : nil;
                            return;
                        }
                    }
                    
                    unknownErrorHandler ? unknownErrorHandler(dataError) : nil;
                    return;
                }
                
                if (!responseObject)
                {
                    noResponseBodyHandler ? noResponseBodyHandler() : nil;
                    return;
                }
                
                completionHandler ? completionHandler(response, responseObject) : nil;
            }];
}

- (NSURLSessionDataTask*)dataTaskWithRequest:(NSURLRequest*)request
                                    withData:(NSData* _Nonnull)data
                          serverErrorHandler:(void(^ _Nullable)(NSHTTPURLResponse* _Nullable httpResponse))serverErrorHandler
                            dataErrorHandler:(void(^ _Nullable)(NSData* _Nullable errorData, NSString* _Nullable errorMessage))dataErrorHandler
                         unknownErrorHandler:(void(^ _Nullable)(NSError* _Nullable dataError))unknownErrorHandler
                       noResponseBodyHandler:(void(^ _Nullable)())noResponseBodyHandler
                           completionHandler:(void(^ _Nullable)(NSURLResponse* _Nonnull response, id _Nullable responseObject))completionHandler
{
    return [super uploadTaskWithRequest:request
                               fromData:data
                               progress:
            ^(NSProgress* _Nonnull uploadProgress)
            {
            }
                      completionHandler:
            ^(NSURLResponse* _Nonnull response, id _Nullable responseObject, NSError* _Nullable dataError)
            {
                if (dataError)
                {
                    DLog(LL_Info, LD_Networking, @"DATAERROR - %@", response.URL);
                    
                    if (dataError.code == NSURLErrorTimedOut)
                    {
                        NSHTTPURLResponse*  httpResponse;
                        if ([response isKindOfClass:[NSHTTPURLResponse class]])
                        {
                            httpResponse    = (NSHTTPURLResponse*)response;
                        }
                        
                        DLog(LL_Info, LD_Networking, @"WILLRETRY - %@", response.URL);
                        [DNUtilities runOnBackgroundThreadAfterDelay:1.0f
                                                               block:
                         ^()
                         {
                             serverErrorHandler ? serverErrorHandler(httpResponse) : nil;
                         }];
                        return;
                    }
                    
                    if ([response isKindOfClass:[NSHTTPURLResponse class]])
                    {
                        NSHTTPURLResponse*    httpResponse    = (NSHTTPURLResponse*)response;
                        if (httpResponse.statusCode == 500)
                        {
                            DLog(LL_Info, LD_Networking, @"WILLRETRY - %@", response.URL);
                            [DNUtilities runOnBackgroundThreadAfterDelay:1.0f
                                                                   block:
                             ^()
                             {
                                 serverErrorHandler ? serverErrorHandler(httpResponse) : nil;
                             }];
                            return;
                        }
                    }
                    
                    NSData*    errorData   = dataError.userInfo[@"com.alamofire.serialization.response.error.data"];
                    NSString*  errorString = [[NSString alloc] initWithData:errorData
                                                                   encoding:NSASCIIStringEncoding];
                    DLog(LL_Debug, LD_General, @"data=%@", errorString);
                    
                    if (errorData)
                    {
                        id jsonData = [NSJSONSerialization JSONObjectWithData:errorData
                                                                      options:0
                                                                        error:nil];
                        if (jsonData)
                        {
                            NSString*  errorMessage    = jsonData[@"error"];
                            
                            dataErrorHandler ? dataErrorHandler(errorData, errorMessage) : nil;
                        }
                    }
                    
                    unknownErrorHandler ? unknownErrorHandler(dataError) : nil;
                    return;
                }
                
                if (!responseObject)
                {
                    noResponseBodyHandler ? noResponseBodyHandler() : nil;
                    return;
                }
                
                completionHandler ? completionHandler(response, responseObject) : nil;
            }];
}

@end
