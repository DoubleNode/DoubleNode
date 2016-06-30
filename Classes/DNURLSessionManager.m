//
//  DNURLSessionManager.m
//  PocketBrew
//
//  Created by Darren Ehlers on 6/29/16.
//  Copyright © 2016 DoubleNode, LLC. All rights reserved.
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

- (NSURLSessionDataTask*)dataTaskWithRequest:(NSURLRequest*)request
                          serverErrorHandler:(void(^ _Nullable)(NSHTTPURLResponse* _Nullable httpResponse))serverErrorHandler
                            dataErrorHandler:(void(^ _Nullable)(NSData* _Nullable errorData, NSString* _Nullable errorMessage))dataErrorHandler
                         unknownErrorHandler:(void(^ _Nullable)(NSError* _Nullable dataError))unknownErrorHandler
                       noResponseBodyHandler:(void(^ _Nullable)())noResponseBodyHandler
                           completionHandler:(void(^ _Nullable)(NSURLResponse* _Nonnull response, id _Nullable responseObject, NSError* _Nullable error))completionHandler
{
    return [super dataTaskWithRequest:request
                    completionHandler:
            ^(NSURLResponse* _Nonnull response, id _Nullable responseObject, NSError* _Nullable dataError)
            {
                if (dataError)
                {
                    DLog(LL_Info, LD_Networking, @"DATAERROR - %@", response.URL);
                    
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
                
                completionHandler ? completionHandler(response, responseObject, dataError) : nil;
            }];
}

@end
