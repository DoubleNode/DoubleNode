//
//  DNStateOptions.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNStateOptions : NSObject

@property (atomic)              BOOL    animated;
@property (atomic)              double  duration;
@property (atomic)              double  fromDuration;
@property (atomic)              double  toDuration;
@property (strong, nonatomic)   void (^completion)(BOOL finished);

+ (id)stateOptions;

@end
