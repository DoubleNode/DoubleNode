//
//  DNModelWatch.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DNModel;

@interface DNModelWatch : NSObject

- (id)initWithModel:(DNModel*)model;

- (void)cancelWatch;
- (void)refreshWatch;

- (void)executeResultsHandler;

@end
