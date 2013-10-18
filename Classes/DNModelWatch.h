//
//  DNModelWatch.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNUtilities.h"

@class DNModel;

@interface DNModelWatch : NSObject

- (id)initWithModel:(DNModel*)model;

- (BOOL)checkWatch;
- (void)cancelWatch;
- (void)refreshWatch;

- (void)executeWillChangeHandler;
- (void)executeDidChangeHandler;

@end
