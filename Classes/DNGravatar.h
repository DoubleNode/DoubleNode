//
//  DNGravatar.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
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

// Rating of Gravatar
enum
{
    GravatarRatingG = 1,
    GravatarRatingPG,
    GravatarRatingR,
    GravatarRatingX
};
typedef NSUInteger GravatarRatings;

// Default Gravatar types: http://bit.ly/1cCmtdb
enum
{
    DefaultGravatar404 = 1,
    DefaultGravatarMysteryMan,
    DefaultGravatarIdenticon,
    DefaultGravatarMonsterID,
    DefaultGravatarWavatar,
    DefaultGravatarRetro,
    DefaultGravatarBlank
};
typedef NSUInteger DefaultGravatars;

@interface DNGravatar : NSObject

@property (readwrite, strong, nonatomic)    NSString*   email;  // User email - you must set this!

@property (readwrite, nonatomic)    NSUInteger          size;               // The size of the gravatar up to 2048. All gravatars are squares, so you will get 2048x2048.
@property (readwrite, nonatomic)    GravatarRatings     rating;             // Rating (G, PG, R, X) of gravatar to allow, helpful for kid-friendly apps.
@property (readwrite, nonatomic)    DefaultGravatars    defaultGravatar;    // If email doesn't have a gravatar, use one of these... http://bit.ly/1cCmtdb
@property (readwrite, nonatomic)    BOOL                forceDefault;       // Force a default gravatar, whether or not email has gravatar. Remember to set defaultGravatar too!

- (NSString*)gravtarURL:(NSString*)email;

@end
