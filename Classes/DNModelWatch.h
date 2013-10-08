//
//  DNModelWatch.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DNModelWatch : NSObject

- (id)init;

- (void)cancelWatch;
- (void)refreshWatch;

- (void)executeResultsHandler;

@end
