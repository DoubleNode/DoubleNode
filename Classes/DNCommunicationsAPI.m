//
//  DNCommunicationsAPI.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNCommunicationsAPI.h"

#import "DNAppConstants.h"

@implementation DNCommunicationsAPIQueued

@end

@interface DNCommunicationsAPI()
{
    NSMutableDictionary*    queues;
    NSMutableDictionary*    failures;
    
    NSDictionary*   plistDictionary;

    NSMutableCharacterSet*  allowedCharacterSet;
}

@end

@implementation DNCommunicationsAPI

+ (id)manager
{
    static DNCommunicationsAPI* sharedManager = nil;
    static dispatch_once_t      onceToken;

    dispatch_once(&onceToken, ^
                  {
                      // Create and return the manager:
                      sharedManager = [[[self class] alloc] init];
                  });

    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        queues      = [NSMutableDictionary dictionary];
        failures    = [NSMutableDictionary dictionary];

        NSString*   filename    = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"API_plist"];
        NSString*   API_Path    = [[NSBundle mainBundle] pathForResource:filename ofType: @"plist"];

        plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:API_Path];

        allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:@"+"];
    }
    
    return self;
}

- (NSURLRequest*)addAuthorizationHeader:(NSURLRequest*)request
{
    return request;
}

- (void)reauthorizeWithSuccess:(void (^)(void))success
                       failure:(void (^)(void))failure
{
}

// Low-level cache functions
- (BOOL)isExpired:(NSString*)cacheKey
          withTTL:(NSUInteger)ttl
{
    NSDate* lastCheck = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
    //DLog(LL_Debug, LD_API, @"[API]%@ lastCheck=%@", cacheKey, lastCheck);
    if (lastCheck)
    {
        NSCalendar*         gregorian   = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSUInteger          unitFlags   = NSDayCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents*   components  = [gregorian components:unitFlags fromDate:lastCheck toDate:[NSDate date] options:0];
        
        NSInteger   days    = [components day];
        NSInteger   minutes = [components minute];
        //DLog(LL_Debug, LD_API, @"days=%d, minutes=%d", days, minutes);
        
        if (minutes < ttl)
        {
            //DLog(LL_Debug, LD_API, @"NOT expired");
            return NO;
        }
    }
    
    //DLog(LL_Debug, LD_API, @"Expired");
    return YES;
}

- (void)markUpdated:(NSString*)cacheKey
{
    [DNUtilities runOnBackgroundThread:^
     {
         [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
         [[NSUserDefaults standardUserDefaults] synchronize];
         //DLog(LL_Debug, LD_API, @"markUpdated [API]%@", cacheKey);
     }];
}

- (void)markExpired:(NSString*)cacheKey
{
    [DNUtilities runOnBackgroundThread:^
     {
         [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
         [[NSUserDefaults standardUserDefaults] synchronize];
         //DLog(LL_Debug, LD_API, @"markExpired [API]%@", cacheKey);
     }];
}

- (NSString*)cacheKey:(DNCommunicationDetails*)commDetails
      withPageDetails:(DNCommunicationPageDetails*)pageDetails
{
    return [commDetails fullPathOfPage:pageDetails];
}

- (BOOL)isCacheExpired:(DNCommunicationDetails*)commDetails
       withPageDetails:(DNCommunicationPageDetails*)pageDetails
               withTTL:(NSUInteger)ttl
{
    return [self isExpired:[self cacheKey:commDetails withPageDetails:pageDetails] withTTL:ttl];
}

- (void)markCacheUpdated:(DNCommunicationDetails*)commDetails
         withPageDetails:(DNCommunicationPageDetails*)pageDetails
{
    [self markUpdated:[self cacheKey:commDetails withPageDetails:pageDetails]];
}

- (void)markCacheExpired:(DNCommunicationDetails*)commDetails
         withPageDetails:(DNCommunicationPageDetails*)pageDetails
{
    [self markExpired:[self cacheKey:commDetails withPageDetails:pageDetails]];
}

- (NSString*)getFirstPartMethod:(NSString*)methodName
{
    NSRange     endRange    = [methodName rangeOfString:@":"];
    if (endRange.location == NSNotFound)
    {
        return methodName;
    }
    return [methodName substringToIndex:endRange.location];
}

- (NSInteger)apiPageSizeRetrieve:(NSString*)apikey
{
    return [self apiPageSizeRetrieve:apikey default:20];
}

- (NSInteger)apiPageSizeRetrieve:(NSString*)apikey
                         default:(NSInteger)defaultPageSize
{
    NSInteger   retval = [[plistDictionary objectForKey:[apikey stringByAppendingString:@"PageSize"]] integerValue];
    if (retval < 1)
    {
        retval = defaultPageSize;
    }

    return retval;
}

- (NSInteger)apiTTLRetrieve:(NSString*)apikey
{
    return [self apiTTLRetrieve:apikey default:5];
}

- (NSInteger)apiTTLRetrieve:(NSString*)apikey
                    default:(NSInteger)defaultTTL
{
    NSInteger   retval = [[plistDictionary objectForKey:[apikey stringByAppendingString:@"TTL"]] integerValue];
    if (retval < 1)
    {
        retval = defaultTTL;
    }
    
    return retval;
}

- (void)resetRetryRecommendation:(NSString*)apikey
{
    [failures removeObjectForKey:apikey];
}

- (NSTimeInterval)retryRecommendation:(NSString*)apikey
{
    NSDate* firstFailure    = [failures objectForKey:apikey];
    if (firstFailure == nil)
    {
        firstFailure    = [NSDate date];
        [failures setObject:firstFailure forKey:apikey];
    }
    
    NSTimeInterval  timeout         = 5.0f;
    NSTimeInterval  timeoutStarted  = fabs([firstFailure timeIntervalSinceNow]);
    
    if (timeoutStarted > 60.0f)     {   timeout = 10.0f;    }
    if (timeoutStarted > 120.0f)    {   timeout = 20.0f;    }
    if (timeoutStarted > 150.0f)    {   timeout = 30.0f;    }
    if (timeoutStarted > 240.0f)    {   timeout = 60.0f;    }
    if (timeoutStarted > 300.0f)    {   timeout = 300.0f;   }
    
    return timeout;
}

- (BOOL)processNow:(DNCommunicationDetails*)commDetails
               now:(void(^)(DNCommunicationDetails* commDetails, NSArray* objects, BOOL isExpired))nowHandler
{
    return [self processNow:commDetails objects:nil filter:nil now:nowHandler];
}

- (BOOL)processNow:(DNCommunicationDetails*)commDetails
           objects:(NSArray*)objects
            filter:(BOOL(^)(id object))filterHandler
               now:(void(^)(DNCommunicationDetails* commDetails, NSArray* objects, BOOL isExpired))nowHandler
{
    BOOL    isExpired = [commDetails enumeratePagesOfSize:[self apiPageSizeRetrieve:commDetails.apikey]
                                               usingBlock:
                         ^BOOL(DNCommunicationPageDetails* pageDetails, NSString* fullpath, BOOL* stop)
                         {
                             NSInteger   ttlMinutes  = [self apiTTLRetrieve:commDetails.apikey];
                             if ([self isCacheExpired:commDetails withPageDetails:pageDetails withTTL:ttlMinutes])
                             {
                                 //DLog(LL_Debug, LD_API, @"processNow:page:EXPIRED [API] %@", commDetails.apikey);
                                 return YES;
                             }

                             //DLog(LL_Debug, LD_API, @"processNow:page:NOT EXPIRED [API] %@", commDetails.apikey);
                             return NO;
                         }];

    NSMutableArray*    results     = [NSMutableArray arrayWithCapacity:[objects count]];

    if (objects && ([objects count] == 0))
    {
        // Only perform check for zero objects when valid objects array is passed in
        DLog(LL_Debug, LD_API, @"ZERO OBJECTS [API]%@", commDetails.apikey);

        isExpired   = YES;  // Force expired when zero objects

        if (nowHandler)
        {
            nowHandler(commDetails, results, isExpired);
        }
        return isExpired;
    }

    if (nowHandler && objects)
    {
        [DNUtilities runOnBackgroundThread:^
         {
             if (!filterHandler)
             {
                 [results addObjectsFromArray:objects];
             }
             else
             {
                 [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                  {
                      if (filterHandler(obj))
                      {
                          [results addObject:obj];
                      }
                  }];
             }

             nowHandler(commDetails, results, isExpired);
         }];
    }

    return isExpired;
}

- (void)processRequest:(DNCommunicationDetails*)commDetails
                filter:(BOOL(^)(id object))filterHandler
              incoming:(NSArray*(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSDictionary* response, NSDictionary* headers))incomingHandler
            completion:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSArray* objects))completionHandler
                 error:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation))errorHandler
{
    [commDetails enumeratePagesOfSize:[self apiPageSizeRetrieve:commDetails.apikey]
                           usingBlock:^BOOL(DNCommunicationPageDetails* pageDetails, NSString* fullpath, BOOL* stop)
     {
         NSURL* URL = [NSURL URLWithString:fullpath];
         DLog(LL_Debug, LD_API, @"urlPath=%@", fullpath);

         NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

         [request setTimeoutInterval:60];
         
         [self subProcessRequest:request commDetails:commDetails pageDetails:pageDetails filter:filterHandler incoming:incomingHandler completion:completionHandler error:errorHandler];

         return YES;
     }];
}

- (void)processPost:(DNCommunicationDetails*)commDetails
             filter:(BOOL(^)(id object))filterHandler
           incoming:(NSArray*(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSDictionary* response, NSDictionary* headers))incomingHandler
         completion:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSArray* objects))completionHandler
              error:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation))errorHandler
{
    NSString*   paramString = [commDetails paramString];
    NSString*   urlPath     = commDetails.path;
    NSURL*      URL         = [NSURL URLWithString:urlPath];
    DLog(LL_Debug, LD_API, @"urlPath=%@", urlPath);
    DLog(LL_Debug, LD_API, @"paramString=%@", paramString);

    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

    [request setTimeoutInterval:60];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];

    [request setHTTPMethod:@"POST"];
    if (!commDetails.files || ([commDetails.files count] == 0))
    {
        NSString*   encodedParamString  = [paramString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];

        [request setHTTPBody:[encodedParamString dataUsingEncoding:NSUTF8StringEncoding]];

        [self subProcessRequest:request commDetails:commDetails pageDetails:nil filter:filterHandler incoming:incomingHandler completion:completionHandler error:errorHandler];
        return;
    }

    [request setTimeoutInterval:10000];

    // set Content-Type in HTTP header
    NSString*   boundary    = @"---------------------------14737809831466499882746641449";
    NSString*   contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    // post body
    NSMutableData*      body    = [NSMutableData data];
    NSMutableString*    bodyStr = [NSMutableString stringWithString:@""];

    {
        NSString*   newStr  = [NSString stringWithFormat:@"--%@\r\n", boundary];
        [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
        [bodyStr appendString:newStr];
    }

    //add (key,value) pairs (no idea why all the \r's and \n's are necessary ... but everyone seems to have them)
    [commDetails.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         {
             NSString*  newStr  = [NSString stringWithFormat:@"--%@\r\n", boundary];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }

         {
             NSString*  newStr  = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }

         {
             NSString*  newStr  = [NSString stringWithFormat:@"%@\r\n", obj];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }
     }];

    [commDetails.files enumerateKeysAndObjectsUsingBlock:
     ^(NSString* key, UIImage* image, BOOL* stop)
    {
        // add image data
        NSData* imageData   = UIImageJPEGRepresentation(image, 0.8f);
        //NSData* imageData   = UIImagePNGRepresentation(image);
        if (imageData)
        {
            {
                NSString*  newStr  = [NSString stringWithFormat:@"--%@\r\n", boundary];
                [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
                [bodyStr appendString:newStr];
            }

            {
                NSString*  newStr  = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", key, key];
                [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
                [bodyStr appendString:newStr];
            }

            {
                NSString*  newStr  = @"Content-Type: application/octet-stream\r\n\r\n";
                [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
                [bodyStr appendString:newStr];
            }

            {
                [body appendData:imageData];
                [bodyStr appendString:[[NSString alloc] initWithData:imageData encoding:NSASCIIStringEncoding]];
            }

            {
                NSString*  newStr  = @"\r\n";
                [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
                [bodyStr appendString:newStr];
            }
        }
        
        // TODO: Support more than 1 file
        *stop   = YES;
    }];

    {
        NSString*  newStr  = [NSString stringWithFormat:@"--%@--\r\n", boundary];
        [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
        [bodyStr appendString:newStr];
    }

    // set the body of the post to the reqeust
    [request setHTTPBody:body];
    //DLog(LL_Debug, LD_API, @"bodyStr=%@", bodyStr);

    // set the content-length
    NSString*   postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [self subProcessRequest:request commDetails:commDetails pageDetails:nil filter:filterHandler incoming:incomingHandler completion:completionHandler error:errorHandler];
}

- (void)subProcessResponse:(NSHTTPURLResponse*)httpResponse
               commDetails:(DNCommunicationDetails*)commDetails
               pageDetails:(DNCommunicationPageDetails*)pageDetails
                 errorCode:(NSInteger)errorCode
                   request:(NSURLRequest*)request
                      data:(NSData*)data
                     retry:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails))retryHandler
                    filter:(BOOL(^)(id object))filterHandler
                  incoming:(NSArray*(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSDictionary* response, NSDictionary* headers))incomingHandler
                completion:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSArray* objects))completionHandler
                     error:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation))errorHandler
{
    NSError*    error = nil;

    //DLog(LL_Debug, LD_API, @"httpResponse=%@", httpResponse);
    DLog(LL_Debug, LD_API, @"responseCode=%d, response=%@, error=%@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]], error);

    DLog(LL_Debug, LD_API, @"dataSize=%d", [data length]);
    /*
     if (data)
     {
     id responseR = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
     DLog(LL_Debug, LD_API, @"responseR=%@", responseR);
     }
     */

    NSInteger      statusCode  = [httpResponse statusCode];

    if (errorCode == -1012)
    {
        statusCode = 401;
    }

    switch (statusCode)
    {
        case 401:  // bad auth_token
        {
            // Unauthorized. Try authenticating and retrying.
            [self reauthorizeWithSuccess:^
             {
                 retryHandler(commDetails, pageDetails);
             }
                                 failure:^
             {
                 errorHandler(commDetails, pageDetails, statusCode, error, [self retryRecommendation:commDetails.apikey]);
             }];

            return;
        }

        case 403:  // device deactivated
        {
            NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
            [userInfoDict setValue:@"This request is forbidden" forKey:NSLocalizedDescriptionKey];

            error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:403 userInfo:userInfoDict];

            break;
        }

        case 422:  // posting data missing
        {
            NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
            [userInfoDict setValue:@"Posting data is missing" forKey:NSLocalizedDescriptionKey];

            error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:422 userInfo:userInfoDict];
            break;
        }

        case 500:  // internal server error
        {
            NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
            [userInfoDict setValue:@"Internal server error" forKey:NSLocalizedDescriptionKey];

            error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:500 userInfo:userInfoDict];
            break;
        }
    }

    NSDictionary*  resultDict  = nil;

    if (((statusCode >= 200) && (statusCode <= 299) && (data != nil)) || (statusCode == 204))
    {
        id responseR = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //DLog(LL_Debug, LD_API, @"responseR=%@", responseR);
        if (responseR && [responseR isKindOfClass:[NSDictionary class]])
        {
            resultDict = responseR;
        }
        else if (responseR && [responseR isKindOfClass:[NSArray class]])
        {
            resultDict = @{ @"objects": responseR };
        }
        else
        {
            resultDict = [NSDictionary dictionary];
        }
    }

    if ((error == nil) && (resultDict == nil))
    {
        NSMutableDictionary*    userInfoDict        = [NSMutableDictionary dictionary];
        NSInteger               httpStatusCode      = statusCode;
        NSString*               errorDescription    = @"Invalid response from server";

        if (!data)
        {
            errorDescription    = @"No data returned from server";

            if (statusCode == 0)
            {
                httpStatusCode      = 408;
                errorDescription    = @"Request Timeout";
            }
        }
        if (data)
        {
            id responseR = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (responseR)
            {
                httpStatusCode  = [responseR[@"code"] integerValue];

                id metaR    = responseR[@"meta"];
                if (metaR)
                {
                    id errorR   = metaR[@"error"];
                    if (errorR)
                    {
                        errorDescription    = errorR;
                    }
                }
            }
        }
        
        [userInfoDict setValue:errorDescription forKey:NSLocalizedDescriptionKey];
        error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:httpStatusCode userInfo:userInfoDict];
    }

    if (error)
    {
        DLog(LL_Debug, LD_API, @"allHeaderFields=%@", [httpResponse allHeaderFields]);

        if (error.code == -1012)
        {
            [DNUtilities setSettingsItem:@"AuthenticationKey" value:@""];

            NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
            [userInfoDict setValue:@"The authentication token for this device is no longer valid" forKey:NSLocalizedDescriptionKey];

            error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:401 userInfo:userInfoDict];
        }

        if (statusCode == 403)
        {
            DLog(LL_Debug, LD_API, @"Forbidden error");
        }

        NSData*    jsonData = data;
        if (jsonData != nil)
        {
            id  userInfo;
            id  responseR = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            if (responseR != nil)
            {
                DLog(LL_Debug, LD_API, @"responseR=%@", responseR);
                
                userInfo    = responseR[@"meta"];

                id  errorMsg    = userInfo[@"error"];
                if (errorMsg && ![errorMsg isEqual:[NSNull null]])
                {
                    userInfo[NSLocalizedDescriptionKey] = errorMsg;
                }
            }
            else
            {
                NSString*  body = [NSString stringWithUTF8String:[jsonData bytes]];
                DLog(LL_Debug, LD_API, @"error body=%@", body);

                if (body)
                {
                    userInfo    = @{ NSLocalizedDescriptionKey: body };
                }
            }

            if (userInfo && ![userInfo isEqual:[NSNull null]])
            {
                error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:error.code userInfo:userInfo];
            }
        }

        DLog(LL_Debug, LD_API, @"responseCode=%d, response=%@, error=%@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]], error);
        errorHandler(commDetails, pageDetails, statusCode, error, [self retryRecommendation:commDetails.apikey]);
        return;
    }

    NSArray*    objects = incomingHandler(commDetails, pageDetails, resultDict, [httpResponse allHeaderFields]);

    if (objects)
    {
        completionHandler(commDetails, pageDetails, objects);
    }
}

- (void)subProcessRequest:(NSURLRequest*)request
              commDetails:(DNCommunicationDetails*)commDetails
              pageDetails:(DNCommunicationPageDetails*)pageDetails
                   filter:(BOOL(^)(id object))filterHandler
                 incoming:(NSArray*(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSDictionary* response, NSDictionary* headers))incomingHandler
               completion:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSArray* objects))completionHandler
                    error:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation))errorHandler
{
    /*
     if ([AppDelegate isReachable] == NO)
     {
     NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
     [userInfoDict setValue:@"The App Server is currently not reachable" forKey:NSLocalizedDescriptionKey];

     NSError*    error   = [NSError errorWithDomain:@"DNCommunicationsAPI" code:1001 userInfo:userInfoDict];
     errorHandler(503, error, [[request URL] absoluteString], [self retryRecommendation:apikey]);
     return;
     }
     */

    NSURLRequest*   finalRequest    = [self addAuthorizationHeader:request];

    DLog(LL_Debug, LD_API, @"headers=%@", [finalRequest allHTTPHeaderFields]);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [NSURLConnection sendAsynchronousRequest:finalRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [DNUtilities runOnBackgroundThread:^
         {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

             DLog(LL_Debug, LD_API, @"mRequest=%@", finalRequest);
             //DLog(LL_Debug, LD_API, @"response=%@", response);

             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

             [self subProcessResponse:httpResponse
                          commDetails:commDetails
                          pageDetails:pageDetails
                            errorCode:error.code
                              request:finalRequest
                                 data:data
                                retry:^(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails)
              {
                  [self subProcessRequest:finalRequest
                              commDetails:commDetails
                              pageDetails:pageDetails
                                   filter:filterHandler
                                 incoming:incomingHandler
                               completion:completionHandler
                                    error:errorHandler];
              }
                               filter:filterHandler
                             incoming:^NSArray*(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSDictionary* response, NSDictionary* headers)
              {
                  [self markCacheUpdated:commDetails withPageDetails:pageDetails];

                  [self resetRetryRecommendation:commDetails.apikey];

                  NSArray*  objects = incomingHandler(commDetails, pageDetails, response, headers);

                  NSMutableArray*   results = [NSMutableArray arrayWithCapacity:[objects count]];

                  [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                   {
                       if ((filterHandler == nil) || filterHandler(obj))
                       {
                           [results addObject:obj];
                       }
                   }];

                  return results;
              }
                           completion:^(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSArray* objects)
              {
                  completionHandler(commDetails, pageDetails, objects);
              }
                                error:^(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSInteger responseCode, NSError* error, NSTimeInterval retryRecommendation)
              {
                  errorHandler(commDetails, pageDetails, responseCode, error, retryRecommendation);
              }];
         }];
     }];
}

- (BOOL)queueProcess:(DNCommunicationDetails*)commDetails
         pageDetails:(DNCommunicationPageDetails*)pageDetails
              filter:(BOOL(^)(id object))filterHandler
            incoming:(NSArray*(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSDictionary* response, NSDictionary* headers))incomingHandler
          completion:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSArray* objects))completionHandler
               error:(void(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSError* error, NSTimeInterval retryRecommendation))errorHandler
{
    NSMutableArray* processQueue    = [queues objectForKey:commDetails.apikey];
    if (processQueue == nil)
    {
        processQueue    = [NSMutableArray array];
        [queues setObject:processQueue forKey:commDetails.apikey];
    }

    DNCommunicationsAPIQueued*  queuedObj  = [[DNCommunicationsAPIQueued alloc] init];
    queuedObj.filterHandler     = filterHandler;
    queuedObj.incomingHandler   = incomingHandler;
    queuedObj.completionHandler = completionHandler;
    queuedObj.errorHandler      = errorHandler;
    [processQueue addObject:queuedObj];
    
    if ([processQueue count] > 1)
    {
        return NO;
    }
    
    return YES;
}

/*
- (void)processPut:(NSString*)apikey
            withID:(id)idValue
        withParams:(NSDictionary*)params
        completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
             error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    __block NSString*   paramString = @"";
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         paramString = [paramString stringByAppendingFormat:@"%@=%@&", key, obj];
     }];

    NSString*   urlPath = [self apiURLRetrieve:[NSString stringWithFormat:@"%@.put", apikey] withID:idValue];
    NSURL*      URL     = [NSURL URLWithString:urlPath];
    DLog(LL_Debug, LD_API, @"urlPath=%@", urlPath);
    DLog(LL_Debug, LD_API, @"paramString=%@", paramString);

    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];

    [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
}

- (void)processPut:(NSString*)apikey
            withID:(id)idValue
        withParams:(NSDictionary*)params
         withFiles:(NSArray*)files
        completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
             error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    __block NSString*   paramString = @"";
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         paramString = [paramString stringByAppendingFormat:@"%@=%@&", key, obj];
     }];

    NSString*   urlPath = [self apiURLRetrieve:[NSString stringWithFormat:@"%@.put", apikey] withID:idValue];
    NSURL*      URL     = [NSURL URLWithString:urlPath];
    DLog(LL_Debug, LD_API, @"urlPath=%@", urlPath);
    DLog(LL_Debug, LD_API, @"paramString=%@", paramString);

    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

    [request setTimeoutInterval:10000];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    // set Content-Type in HTTP header
    NSString*   boundary    = @"---------------------------14737809831466499882746641449";
    NSString*   contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    // post body
    NSMutableData*      body    = [NSMutableData data];
    NSMutableString*    bodyStr = [NSMutableString stringWithString:@""];

    {
        NSString*   newStr  = [NSString stringWithFormat:@"--%@\r\n",boundary];
        [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
        [bodyStr appendString:newStr];
    }

    //add (key,value) pairs (no idea why all the \r's and \n's are necessary ... but everyone seems to have them)
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         {
             NSString*  newStr  = [NSString stringWithFormat:@"--%@\r\n", boundary];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }

         {
             NSString*  newStr  = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }

         {
             NSString*  newStr  = [NSString stringWithFormat:@"%@\r\n", obj];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }
     }];

    // add image data
    NSData* imageData = UIImagePNGRepresentation(files[0]);
    if (imageData)
    {
        {
            NSString*  newStr  = [NSString stringWithFormat:@"--%@\r\n", boundary];
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }

        {
            NSString*  newStr  = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"signature.png\"\r\n", @"visitor_log[signature]"];
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }

        {
            NSString*  newStr  = @"Content-Type: application/octet-stream\r\n\r\n";
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }

        {
            [body appendData:imageData];
            [bodyStr appendString:[[NSString alloc] initWithData:imageData encoding:NSASCIIStringEncoding]];
        }

        {
            NSString*  newStr  = @"\r\n";
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }
    }

    {
        NSString*  newStr  = [NSString stringWithFormat:@"--%@--\r\n", boundary];
        [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
        [bodyStr appendString:newStr];
    }

    // set the body of the post to the reqeust
    [request setHTTPBody:body];
    DLog(LL_Debug, LD_API, @"bodyStr=%@", bodyStr);

    // set the content-length
    NSString*   postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
}

- (void)processPost:(NSString*)apikey
         withParams:(NSDictionary*)params
         completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    [self processPost:apikey withID:nil withParams:params completion:completionHandler error:errorHandler];
}

- (void)processPost:(NSString*)apikey
             withID:(id)idValue
         withParams:(NSDictionary*)params
         completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    __block NSString*   paramString = @"";
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         paramString = [paramString stringByAppendingFormat:@"%@=%@&", key, obj];
     }];
    
    NSString*   urlPath = [self apiURLRetrieve:apikey withID:idValue];
    NSURL*      URL     = [NSURL URLWithString:urlPath];
    DLog(LL_Debug, LD_API, @"urlPath=%@", urlPath);
    DLog(LL_Debug, LD_API, @"paramString=%@", paramString);
    
    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
}

- (void)processPost:(NSString*)apikey
         withParams:(NSDictionary*)params
          withFiles:(NSArray*)files
         completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
              error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    __block NSString*   paramString = @"";
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         paramString = [paramString stringByAppendingFormat:@"%@=%@&", key, obj];
     }];
    
    NSString*   urlPath = [self apiURLRetrieve:apikey];
    NSURL*      URL     = [NSURL URLWithString:urlPath];
    DLog(LL_Debug, LD_API, @"urlPath=%@", urlPath);
    DLog(LL_Debug, LD_API, @"paramString=%@", paramString);
    
    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

    [request setTimeoutInterval:10000];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString*   boundary    = @"---------------------------14737809831466499882746641449";
    NSString*   contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData*      body    = [NSMutableData data];
    NSMutableString*    bodyStr = [NSMutableString stringWithString:@""];
    
    {
        NSString*   newStr  = [NSString stringWithFormat:@"--%@\r\n",boundary];
        [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
        [bodyStr appendString:newStr];
    }
    
    //add (key,value) pairs (no idea why all the \r's and \n's are necessary ... but everyone seems to have them)
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         {
             NSString*  newStr  = [NSString stringWithFormat:@"--%@\r\n", boundary];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }

         {
             NSString*  newStr  = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }
         
         {
             NSString*  newStr  = [NSString stringWithFormat:@"%@\r\n", obj];
             [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
             [bodyStr appendString:newStr];
         }
     }];
    
    // add image data
    NSData* imageData = UIImagePNGRepresentation(files[0]);
    if (imageData)
    {
        {
            NSString*  newStr  = [NSString stringWithFormat:@"--%@\r\n", boundary];
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }
        
        {
            NSString*  newStr  = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"signature.png\"\r\n", @"visitor_log[signature]"];
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }
        
        {
            NSString*  newStr  = @"Content-Type: application/octet-stream\r\n\r\n";
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }
        
        {
            [body appendData:imageData];
            [bodyStr appendString:[[NSString alloc] initWithData:imageData encoding:NSASCIIStringEncoding]];
        }
        
        {
            NSString*  newStr  = @"\r\n";
            [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
            [bodyStr appendString:newStr];
        }
    }

    {
        NSString*  newStr  = [NSString stringWithFormat:@"--%@--\r\n", boundary];
        [body appendData:[newStr dataUsingEncoding:NSASCIIStringEncoding]];
        [bodyStr appendString:newStr];
    }
    
    // set the body of the post to the reqeust
    [request setHTTPBody:body];
    DLog(LL_Debug, LD_API, @"bodyStr=%@", bodyStr);
    
    // set the content-length
    NSString*   postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
}

 - (void)processingCompletionBlock:(DNCommunicationDetails*)commDetails
                      pageDetails:(DNCommunicationPageDetails*)pageDetails
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filterHandler
                       completion:(NSArray*(^)(DNCommunicationDetails* commDetails, DNCommunicationPageDetails* pageDetails, NSArray* objects))completionHandler
{
    [self markCacheUpdated:commDetails withPageDetails:pageDetails];

    NSMutableArray*    results     = [NSMutableArray arrayWithCapacity:[objects count]];

    [DNUtilities runOnBackgroundThread:^
     {
         [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
          {
              if ((filterHandler == nil) || filterHandler(obj))
              {
                  [results addObject:obj];
              }
          }];

         completionHandler(commDetails, pageDetails, results);
     }];
}

- (void)processingQueueCompletionBlock:(NSString*)apikey
                               objects:(NSArray*)objects
{
    NSMutableArray* processQueue    = [queues objectForKey:apikey];
    if ((processQueue == nil) || ([processQueue count] == 0))
    {
        return;
    }
    [queues removeObjectForKey:apikey];
    
    [processQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         DNCommunicationsAPIQueued* queuedObj = obj;
         
         [self processingCompletionBlock:apikey
                                 objects:objects
                                  filter:queuedObj.filterHandler
                              completion:queuedObj.completionHandler];
     }];
}

- (void)processingQueueErrorBlock:(NSString*)apikey
                     responseCode:(NSInteger)responseCode
                            error:(NSError*)error
                              url:(NSString*)url
              retryRecommendation:(NSTimeInterval)retryRecommendation
{
    DLog(LL_Debug, LD_API, @"responseCode=%d, error=%@", responseCode, error);
    
    NSMutableArray* processQueue    = [queues objectForKey:apikey];
    if ((processQueue == nil) || ([processQueue count] == 0))
    {
        return;
    }
    [queues removeObjectForKey:apikey];
    
    [processQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         DNCommunicationsAPIQueued* queuedObj = obj;
         
         queuedObj.errorHandler(error, url, retryRecommendation);
     }];
}
*/

@end
