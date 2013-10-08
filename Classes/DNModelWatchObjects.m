//
//  DNModelWatchObjects.m
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatchObjects.h"

@interface DNModelWatchObjects ()
{
    DNModelWatchObjects_resultsHandlerBlock resultsHandler;
}

@end

@implementation DNModelWatchObjects

- (id)initWithModel:(DNModel*)model
         andHandler:(DNModelWatchObjects_resultsHandlerBlock)handler
{
    self = [super initWithModel:model];
    if (self)
    {
        resultsHandler  = handler;
    }
    
    return self;
}

- (NSArray*)objects
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
        resultsHandler(self, [self objects]);
    }
}

@end
