//
//  DNGravatar.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//
//  Derived from work originally created by Rudd Fawcett
//  Portions Copyright (c) 2013 Rudd Fawcett.
//  All rights reserved.
//  https://www.cocoacontrols.com/controls/uiimageview-gravatar
//

#import <CommonCrypto/CommonDigest.h>

#import "DNGravatar.h"

@implementation DNGravatar

- (NSString*)gravtarURL:(NSString*)email
{
    NSMutableString*    gravatarPath = [NSMutableString stringWithFormat:@"https://gravatar.com/avatar/%@?", [self createMD5:email]];

    return [self buildLink:gravatarPath];
}

- (NSMutableString*)buildLink:(NSMutableString*)baseLink
{
    if (_size)
    {
        [baseLink appendString:[NSString stringWithFormat:@"&size=%lu", (unsigned long)_size]];
    }

    if (_rating)
    {
        switch (_rating)
        {
            case GravatarRatingG:   {   [baseLink appendString:@"&rating=g"];   break;  }
            case GravatarRatingPG:  {   [baseLink appendString:@"&rating=pg"];  break;  }
            case GravatarRatingR:   {   [baseLink appendString:@"&rating=r"];   break;  }
            case GravatarRatingX:   {   [baseLink appendString:@"&rating=x"];   break;  }

            default:    {   break;  }
        }
    }

    if (_defaultGravatar)
    {
        switch (_defaultGravatar)
        {
            case DefaultGravatar404:        {   [baseLink appendString:@"&default=404"];        break;  }
            case DefaultGravatarMysteryMan: {   [baseLink appendString:@"&default=mm"];         break;  }
            case DefaultGravatarIdenticon:  {   [baseLink appendString:@"&default=identicon"];  break;  }
            case DefaultGravatarMonsterID:  {   [baseLink appendString:@"&default=monsterid"];  break;  }
            case DefaultGravatarWavatar:    {   [baseLink appendString:@"&default=wavatar"];    break;  }
            case DefaultGravatarRetro:      {   [baseLink appendString:@"&default=retro"];      break;  }
            case DefaultGravatarBlank:      {   [baseLink appendString:@"&default=blank"];      break;  }

            default:    {   break;  }
        }
    }

    if (_forceDefault)
    {
        [baseLink appendString:@"&forcedefault=y"];
    }

    return baseLink;
}

- (NSString*)createMD5:(NSString*)email
{
    const char*     cStr = [email UTF8String];
    unsigned char   digest[16];

    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString*    emailMD5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [emailMD5 appendFormat:@"%02x", digest[i]];
    }

    return emailMD5;
}

@end
