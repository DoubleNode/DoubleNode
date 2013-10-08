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

- (id)initWithHandler:(DNModelWatchObjects_resultsHandlerBlock)handler
{
    self = [super init];
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
