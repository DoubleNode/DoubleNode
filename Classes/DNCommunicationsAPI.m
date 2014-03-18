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
    [self markUpdated:[self apiURLRetrieve:apikey]];
}

- (void)markUpdated:(NSString*)cacheKey
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
}

- (void)markExpired:(NSString*)cacheKey
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"[API]%@", cacheKey]];
}

- (NSString*)getAPIHostname
{
    return [[NSURL URLWithString:[self getAPIHostnameString]] host];
}

- (NSString*)getAPIHostnameString
{
    return [plistDictionary objectForKey:@"Hostname"];
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

    NSString*       result      = [url absoluteString];
    return result;
    //return [url absoluteString];
}

- (NSInteger)apiTTLRetrieve:(NSString*)apikey
{
    return [self apiTTLRetrieve:apikey default:60];
}

- (NSInteger)apiTTLRetrieve:(NSString*)apikey
                    default:(NSInteger)defaultTTL
{
//#ifdef DEBUG
//    return 1;
//#endif

    NSInteger   retval = [[plistDictionary objectForKey:[apikey stringByAppendingString:@"TTL"]] integerValue];
    if (retval < 1)
    {
        retval = 60;
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
            completion:(void(^)(NSDictionary* response))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    [self processRequest:apikey withParamString:@"" completion:completionHandler error:errorHandler];
}

- (void)processRequest:(NSString*)apikey
                withID:(id)idValue
            completion:(void(^)(NSDictionary* response))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    [self processRequest:apikey withID:nil withParamString:nil completion:completionHandler error:errorHandler];
}

- (void)processRequest:(NSString*)apikey
       withParamString:(NSString*)params
            completion:(void(^)(NSDictionary* response))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    [self processRequest:apikey withID:nil withParamString:params completion:completionHandler error:errorHandler];
}

- (void)processRequest:(NSString*)apikey
                withID:(id)idValue
       withParamString:(NSString*)params
            completion:(void(^)(NSDictionary* response))completionHandler
                 error:(void(^)(NSInteger responseCode, NSError* error, NSString* url, NSTimeInterval retryRecommendation))errorHandler
{
    NSString*   paramString = @"";
    if ([params length] > 0)
    {
        paramString = [paramString stringByAppendingFormat:@"%@&", params];
    }
    
    NSString*   urlPath = [NSString stringWithFormat:@"%@?%@", [self apiURLRetrieve:apikey withID:idValue], paramString];
    NSURL*      URL     = [NSURL URLWithString:urlPath];
    DLog(LL_Debug, LD_API, @"urlPath=%@", urlPath);

    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];

    AFOAuthCredential*  oauthCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:[DNAppConstants oAuthCredentialIdentifier]];
    DLog(LL_Debug, LD_API, @"accessToken=%@", [oauthCredential accessToken]);
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [oauthCredential accessToken]] forHTTPHeaderField:@"Authorization"];

    [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
}

- (void)processPut:(NSString*)apikey
            withID:(id)idValue
        withParams:(NSDictionary*)params
        completion:(void(^)(NSDictionary* response))completionHandler
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

    DLog(LL_Debug, LD_API, @"auth_token=%@", [DNUtilities settingsItem:@"AuthenticationKey" default:@""]);

    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:[DNUtilities settingsItem:@"AuthenticationKey" default:@""] forHTTPHeaderField:@"auth_token"];

    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];

    [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
}

- (void)processPut:(NSString*)apikey
            withID:(id)idValue
        withParams:(NSDictionary*)params
         withFiles:(NSArray*)files
        completion:(void(^)(NSDictionary* response))completionHandler
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

    DLog(LL_Debug, LD_API, @"auth_token=%@", [DNUtilities settingsItem:@"AuthenticationKey" default:@""]);

    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:[DNUtilities settingsItem:@"AuthenticationKey" default:@""] forHTTPHeaderField:@"auth_token"];

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
         completion:(void(^)(NSDictionary* response))completionHandler
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
    
    DLog(LL_Debug, LD_API, @"auth_token=%@", [DNUtilities settingsItem:@"AuthenticationKey" default:@""]);
    
    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:[DNUtilities settingsItem:@"AuthenticationKey" default:@""] forHTTPHeaderField:@"auth_token"];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self subProcessRequest:request apikey:apikey completion:completionHandler error:errorHandler];
}

- (void)processPost:(NSString*)apikey
         withParams:(NSDictionary*)params
          withFiles:(NSArray*)files
         completion:(void(^)(NSDictionary* response))completionHandler
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
    
    DLog(LL_Debug, LD_API, @"auth_token=%@", [DNUtilities settingsItem:@"AuthenticationKey" default:@""]);
    
    NSMutableURLRequest*    request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:[DNUtilities settingsItem:@"AuthenticationKey" default:@""] forHTTPHeaderField:@"auth_token"];
    
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

- (void)subProcessRequest:(NSURLRequest*)request
                   apikey:(NSString*)apikey
               completion:(void(^)(NSDictionary* response))completionHandler
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

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
         
         DLog(LL_Debug, LD_API, @"request=%@", request);
         DLog(LL_Debug, LD_API, @"httpResponse=%@", httpResponse);
         DLog(LL_Debug, LD_API, @"responseCode=%d, response=%@, error=%@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]], error);
         
         NSInteger  statusCode  = [httpResponse statusCode];
         switch (statusCode)
         {
             case 401:  // bad auth_token
             {
                 [DNUtilities setSettingsItem:@"AuthenticationKey" value:@""];

                 NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
                 [userInfoDict setValue:@"The authentication token for this device is no longer valid" forKey:NSLocalizedDescriptionKey];
                 
                 error  = [NSError errorWithDomain:@"DNCommunicationsAPI" code:401 userInfo:userInfoDict];
                 break;
             }

             case 403:  // device deactivated
             {
                 [DNUtilities setSettingsItem:@"AuthenticationKey" value:@""];
                 
                 NSMutableDictionary*    userInfoDict = [NSMutableDictionary dictionary];
                 [userInfoDict setValue:@"This device has been deactivated" forKey:NSLocalizedDescriptionKey];
                 
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
         NSData*        jsonData    = data;
         
         if (((statusCode >= 200) && (statusCode <= 299) && (jsonData != nil)) || (statusCode == 204))
         {
             id responseR = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
             DLog(LL_Debug, LD_API, @"responseR=%@", responseR);
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
         
         completionHandler(resultDict);
         [self resetRetryRecommendation:apikey];
     }];
}

- (BOOL)processingNowBlock:(NSString*)apikey
                   objects:(NSArray*)objects
                    filter:(BOOL(^)(id object))filterHandler
                       now:(void(^)(NSArray* speakers, BOOL isExpired))nowHandler
{
    return [self processingNowBlock:apikey withID:nil withParamString:nil objects:objects filter:filterHandler now:nowHandler];
}

- (BOOL)processingNowBlock:(NSString*)apikey
                    withID:(id)idValue
                   objects:(NSArray*)objects
                    filter:(BOOL(^)(id object))filterHandler
                       now:(void(^)(NSArray* speakers, BOOL isExpired))nowHandler
{
    return [self processingNowBlock:apikey withID:idValue withParamString:nil objects:objects filter:filterHandler now:nowHandler];
}

- (BOOL)processingNowBlock:(NSString*)apikey
                    withID:(id)idValue
           withParamString:(NSString*)params
                   objects:(NSArray*)objects
                    filter:(BOOL(^)(id object))filterHandler
                       now:(void(^)(NSArray* speakers, BOOL isExpired))nowHandler
{
    NSString*   paramString = @"";
    if ([params length] > 0)
    {
        paramString = [paramString stringByAppendingFormat:@"%@&", params];
    }

    NSString*   urlPath     = [NSString stringWithFormat:@"%@?%@", [self apiURLRetrieve:apikey withID:idValue], paramString];
    NSInteger   ttlMinutes  = [self apiTTLRetrieve:apikey];
    BOOL        isExpired   = [self isExpired:urlPath withTTL:ttlMinutes];
    
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
                            nowHandler(results, isExpired);
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
    [self markAPIKeyUpdated:apikey];

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
