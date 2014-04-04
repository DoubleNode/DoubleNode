//
//  DNCommunicationsAPI.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <AFOAuth2Client/AFOAuth2Client.h>

#import "DNCommunicationsAPI.h"

#import "DNAppConstants.h"

@implementation DNCommunicationsAPIQueued

@end

@interface DNCommunicationsAPI()
{
    NSMutableDictionary*    queues;
    NSMutableDictionary*    failures;
    
    NSDictionary*   plistDictionary;
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
        
        NSString*       API_Path    = [[NSBundle mainBundle] pathForResource:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"API_plist"] ofType: @"plist"];
        plistDictionary             = [[NSDictionary alloc] initWithContentsOfFile:API_Path];
    }
    
    return self;
}

- (void)reauthorizeWithSuccess:(void (^)(void))success
                       failure:(void (^)(void))failure
{
}

- (BOOL)isExpired:(NSString*)cacheKey
          withTTL:(NSUInteger)ttl
{
    NSDate* lastCheck = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
    DLog(LL_Debug, LD_API, @"[API]%@ lastCheck=%@", cacheKey, lastCheck);
    if (lastCheck)
    {
        NSCalendar*         gregorian   = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSUInteger          unitFlags   = NSDayCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents*   components  = [gregorian components:unitFlags fromDate:lastCheck toDate:[NSDate date] options:0];
        
        NSInteger   days    = [components day];
        NSInteger   minutes = [components minute];
        DLog(LL_Debug, LD_API, @"days=%d, minutes=%d", days, minutes);
        
        if (minutes < ttl)
        {
            DLog(LL_Debug, LD_API, @"NOT expired");
            return NO;
        }
    }
    
    DLog(LL_Debug, LD_API, @"Expired");
    return YES;
}

- (void)markAPIKeyUpdated:(NSString*)apikey
{
    [self markAPIKeyUpdated:apikey withID:nil withParamString:nil];
}

- (void)markAPIKeyUpdated:(NSString*)apikey
                   withID:(id)idValue
{
    [self markAPIKeyUpdated:apikey withID:idValue withParamString:nil];
}

- (void)markAPIKeyUpdated:(NSString*)apikey
                   withID:(id)idValue
          withParamString:(NSString*)params
{
    NSString*   paramString = @"";
    if ([params length] > 0)
    {
        paramString = [paramString stringByAppendingFormat:@"%@&", params];
    }

    NSString*   urlPath = [NSString stringWithFormat:@"%@?%@", [self apiURLRetrieve:apikey withID:idValue], paramString];

    [self markUpdated:urlPath];
}

- (void)markAPIKeyExpired:(NSString*)apikey
{
    [self markAPIKeyExpired:apikey withID:nil withParamString:nil];
}

- (void)markAPIKeyExpired:(NSString*)apikey
                   withID:(id)idValue
{
    [self markAPIKeyExpired:apikey withID:idValue withParamString:nil];
}

- (void)markAPIKeyExpired:(NSString*)apikey
                   withID:(id)idValue
          withParamString:(NSString*)params
{
    NSString*   paramString = @"";
    if ([params length] > 0)
    {
        paramString = [paramString stringByAppendingFormat:@"%@&", params];
    }

    NSString*   urlPath = [NSString stringWithFormat:@"%@?%@", [self apiURLRetrieve:apikey withID:idValue], paramString];

    [self markExpired:urlPath];
}

- (void)markUpdated:(NSString*)cacheKey
{
    [DNUtilities runAfterDelay:0.01f
                         block:^
     {
         [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
     }];
}

- (void)markExpired:(NSString*)cacheKey
{
    [DNUtilities runAfterDelay:0.01f
                         block:^
     {
         [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
     }];
}

- (NSString*)getAPIHostname
{
    return [[NSURL URLWithString:[self getAPIHostnameString]] host];
}

- (NSString*)getAPIHostnameString
{
    return [DNAppConstants apiHostname];
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

- (NSString*)apiURLRetrieve:(NSString*)apikey
{
    return [self apiURLRetrieve:apikey withID:nil];
}

- (NSString*)apiURLRetrieve:(NSString*)apikey
                     withID:(id)idValue
{
    NSString*       hostnameStr = [self getAPIHostnameString];
    NSURL*          hostname    = [NSURL URLWithString:hostnameStr];

    NSString*       urlStr      = [plistDictionary objectForKey:apikey];
    if (idValue)
    {
        urlStr  = [NSString stringWithFormat:urlStr, idValue];
    }
    NSURL*          url         = [NSURL URLWithString:urlStr relativeToURL:hostname];
    return [url absoluteString];
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
    return [self apiTTLRetrieve:apikey default:60];
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

- (void)processRequest:(NSString*)apikey
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    [self processRequest:apikey withParamString:@"" offset:offset count:count completion:completionHandler error:errorHandler];
}

- (void)processRequest:(NSString*)apikey
                withID:(id)idValue
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    [self processRequest:apikey withID:idValue withParamString:nil offset:offset count:count completion:completionHandler error:errorHandler];
}

- (void)processRequest:(NSString*)apikey
       withParamString:(NSString*)params
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    [self processRequest:apikey withID:nil withParamString:params offset:offset count:count completion:completionHandler error:errorHandler];
}

- (void)processRequest:(NSString*)apikey
                withID:(id)idValue
       withParamString:(NSString*)params
                offset:(NSUInteger)offset
                 count:(NSUInteger)count
            completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    NSString*   paramString = @"";
    if ([params length] > 0)
    {
        paramString = [paramString stringByAppendingFormat:@"%@&", params];
    }

    NSInteger   pageSize    = [self apiPageSizeRetrieve:apikey];

    NSUInteger  normalizedCount = (count == 0) ? 0 : (count - 1);
    NSUInteger  firstPage       = (offset / pageSize) + 1;
    NSUInteger  lastPage        = firstPage + (normalizedCount / pageSize);
    for (NSUInteger page = firstPage; page <= lastPage; page++)
    {
        NSString*   urlPath = [NSString stringWithFormat:@"%@?%@items_per_page=%d&page=%d", [self apiURLRetrieve:apikey withID:idValue], paramString, pageSize, page];
        NSURL*      URL     = [NSURL URLWithString:urlPath];
        DLog(LL_Debug, LD_API, @"urlPath=%@", urlPath);

        NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

        [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
    }
}

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

- (void)subProcessResponse:(NSHTTPURLResponse*)httpResponse
                 errorCode:(NSInteger)errorCode
                    apikey:(NSString*)apikey
                   request:(NSURLRequest*)request
                      data:(NSData*)data
                     retry:(void(^)())retryHandler
                completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                     error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    NSError*    error = nil;

    DLog(LL_Debug, LD_API, @"httpResponse=%@", httpResponse);
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
                 retryHandler();
             }
                                 failure:^
             {
                 errorHandler(statusCode, error, [[request URL] absoluteString], [self retryRecommendation:apikey]);
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
        NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
        [userInfoDict setValue:@"Invalid response from server" forKey:NSLocalizedDescriptionKey];

        error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:420 userInfo:userInfoDict];
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

        NSData*    jsonData = data;
        if (jsonData != nil)
        {
            id responseR = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            DLog(LL_Debug, LD_API, @"responseR=%@", responseR);
        }
        else if (jsonData != nil)
        {
            NSString*  body = [NSString stringWithUTF8String:[jsonData bytes]];
            DLog(LL_Debug, LD_API, @"error body=%@", body);
        }

        DLog(LL_Debug, LD_API, @"responseCode=%d, response=%@, error=%@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]], error);
        errorHandler(statusCode, error, [[request URL] absoluteString], [self retryRecommendation:apikey]);
        return;
    }

    completionHandler(resultDict, [httpResponse allHeaderFields]);
}

- (void)subProcessRequest:(NSURLRequest*)request
                   apikey:(NSString*)apikey
               completion:(void(^)(NSDictionary* response, NSDictionary* headers))completionHandler
                    error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
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

    NSMutableURLRequest*    mRequest    = [request mutableCopy];

    AFOAuthCredential*  oauthCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:[DNAppConstants oAuthCredentialIdentifier]];
    DLog(LL_Debug, LD_API, @"accessToken=%@", [oauthCredential accessToken]);
    [mRequest setValue:[NSString stringWithFormat:@"Bearer %@", [oauthCredential accessToken]] forHTTPHeaderField:@"Authorization"];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [NSURLConnection sendAsynchronousRequest:mRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         DLog(LL_Debug, LD_API, @"mRequest=%@", mRequest);
         DLog(LL_Debug, LD_API, @"response=%@", response);

         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
         
         [self subProcessResponse:httpResponse
                        errorCode:error.code
                           apikey:apikey
                          request:mRequest
                             data:data
                            retry:^
          {
              [self subProcessRequest:mRequest
                               apikey:apikey
                           completion:completionHandler
                                error:errorHandler];
          }
                       completion:^(NSDictionary* response, NSDictionary* headers)
          {
              completionHandler(response, headers);
              [self resetRetryRecommendation:apikey];
          }
                            error:^(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation)
          {
              errorHandler(responseCode, error, url, retryRecommendation);
          }];
     }];
}

- (BOOL)processingNowBlock:(NSString*)apikey
                    offset:(NSUInteger)offset
                     count:(NSUInteger)count
                   objects:(NSArray*)objects
                    filter:(BOOL(^)(id object))filterHandler
                       now:(void(^)(NSArray* speakers, BOOL isExpired))nowHandler
{
    return [self processingNowBlock:apikey withID:nil withParamString:nil offset:offset count:count objects:objects filter:filterHandler now:nowHandler];
}

- (BOOL)processingNowBlock:(NSString*)apikey
                    withID:(id)idValue
                    offset:(NSUInteger)offset
                     count:(NSUInteger)count
                   objects:(NSArray*)objects
                    filter:(BOOL(^)(id object))filterHandler
                       now:(void(^)(NSArray* speakers, BOOL isExpired))nowHandler
{
    return [self processingNowBlock:apikey withID:idValue withParamString:nil offset:offset count:count objects:objects filter:filterHandler now:nowHandler];
}

- (BOOL)processingNowBlock:(NSString*)apikey
                    withID:(id)idValue
           withParamString:(NSString*)params
                    offset:(NSUInteger)offset
                     count:(NSUInteger)count
                   objects:(NSArray*)objects
                    filter:(BOOL(^)(id object))filterHandler
                       now:(void(^)(NSArray* speakers, BOOL isExpired))nowHandler
{
    NSString*   paramString = @"";
    if ([params length] > 0)
    {
        paramString = [paramString stringByAppendingFormat:@"%@&", params];
    }

    BOOL        isExpired   = NO;
    NSInteger   pageSize    = [self apiPageSizeRetrieve:apikey];

    NSUInteger  normalizedCount = (count == 0) ? 0 : (count - 1);
    NSUInteger  firstPage       = (offset / pageSize) + 1;
    NSUInteger  lastPage        = firstPage + (normalizedCount / pageSize);
    for (NSUInteger page = firstPage; page <= lastPage; page++)
    {
        NSString*   urlPath     = [NSString stringWithFormat:@"%@?%@items_per_page=%d&page=%d", [self apiURLRetrieve:apikey withID:idValue], paramString, pageSize, page];
        NSInteger   ttlMinutes  = [self apiTTLRetrieve:apikey];
        if ([self isExpired:urlPath withTTL:ttlMinutes])
        {
            isExpired = YES;
        }
    }

    NSMutableArray*    results     = [NSMutableArray arrayWithCapacity:[objects count]];
    
    if ([objects count] == 0)
    {
        DLog(LL_Debug, LD_API, @"ZERO OBJECTS [API]%@", apikey);
        return YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                        {
                            if ((filterHandler == nil) || filterHandler(obj))
                            {
                                [results addObject:obj];
                            }
                        }];

                       [DNUtilities runAfterDelay:0.0f block:^
                        {
                            if (nowHandler)
                            {
                                nowHandler(results, isExpired);
                            }
                        }];
                   });
    
    return isExpired;
}

- (BOOL)queueProcess:(NSString*)apikey
              filter:(BOOL(^)(id object))filterHandler
          completion:(void(^)(NSArray* speakers))completionHandler
               error:(void(^)(NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    NSMutableArray* processQueue    = [queues objectForKey:apikey];
    if (processQueue == nil)
    {
        processQueue    = [NSMutableArray array];
        [queues setObject:processQueue forKey:apikey];
    }
    
    DNCommunicationsAPIQueued*  queuedObj  = [[DNCommunicationsAPIQueued alloc] init];
    queuedObj.filterHandler     = filterHandler;
    queuedObj.completionHandler = completionHandler;
    queuedObj.errorHandler      = errorHandler;
    [processQueue addObject:queuedObj];
    
    if ([processQueue count] > 1)
    {
        return NO;
    }
    
    return YES;
}

- (void)processingCompletionBlock:(NSString*)apikey
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filterHandler
                       completion:(void(^)(NSArray* speakers))completionHandler
{
    [self processingCompletionBlock:apikey withID:nil withParamString:nil objects:objects filter:filterHandler completion:completionHandler];
}

- (void)processingCompletionBlock:(NSString*)apikey
                           withID:(id)idValue
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filterHandler
                       completion:(void(^)(NSArray* speakers))completionHandler
{
    [self processingCompletionBlock:apikey withID:idValue withParamString:nil objects:objects filter:filterHandler completion:completionHandler];
}

- (void)processingCompletionBlock:(NSString*)apikey
                           withID:(id)idValue
                  withParamString:(NSString*)params
                          objects:(NSArray*)objects
                           filter:(BOOL(^)(id object))filterHandler
                       completion:(void(^)(NSArray* speakers))completionHandler
{
    [self markAPIKeyUpdated:apikey withID:idValue withParamString:params];

    NSMutableArray*    results     = [NSMutableArray arrayWithCapacity:[objects count]];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                        {
                            if ((filterHandler == nil) || filterHandler(obj))
                            {
                                [results addObject:obj];
                            }
                        }];
                       
                       [DNUtilities runAfterDelay:0.0f block:^
                        {
                            completionHandler(results);
                        }];
                   });
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

@end
