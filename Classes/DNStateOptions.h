//
//  DNStateOptions.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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
