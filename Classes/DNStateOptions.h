//
//  DNStateOptions.h
//  Phoenix
//
//  Created by Darren Ehlers on 11/10/13.
//  Copyright (c) 2013 Table Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNStateOptions : NSObject

@property (atomic)              BOOL animated;
@property (strong, nonatomic)   void (^completion)(BOOL finished);

+ (id)stateOptions;

@end
