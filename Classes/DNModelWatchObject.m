//
//  DNModelWatchObject.m
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatchObject.h"

@interface DNModelWatchObject ()
{
    DNModelWatchObject_resultsHandlerBlock  resultsHandler;
}

@end

@implementation DNModelWatchObject

- (id)initWithModel:(DNModel*)model
         andHandler:(DNModelWatchObject_resultsHandlerBlock)handler
{
    self = [super initWithModel:model];
    if (self)
    {
        resultsHandler  = handler;
    }
    
    return self;
}

- (DNManagedObject*)object;
{
    return nil;
}

- (void)cancelWatch
{
    [super cancelWatch];
    
    resultsHandler          = nil;
}

- (void)executeResultsHandler
{
    if (resultsHandler)
    {
        resultsHandler(self, [self object]);
    }
}

@end
