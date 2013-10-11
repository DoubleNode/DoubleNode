//
//  DNModelWatchKVOObjects.m
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNModelWatchKVOObjects.h"

@interface DNModelWatchKVOObjects ()
{
    NSArray*    objects;
}

@end

@implementation DNModelWatchKVOObjects

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects
           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    return [[DNModelWatchKVOObjects alloc] initWithModel:model andObjects:objects didChange:handler];
}

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)pObjects
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    self = [super initWithModel:model didChange:handler];
    if (self)
    {
        objects = pObjects;
        
        [objects enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
         {
             [object addObserver:self
                      forKeyPath:@"key"
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:nil];
             [object addObserver:self
                      forKeyPath:@"value"
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:nil];
         }];
        
        [self refreshWatch];
    }
    
    return self;
}

- (NSArray*)objects
{
    return objects;
}

- (void)cancelWatch
{
    [super cancelWatch];
    
    [objects enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
     {
         [object removeObserver:self forKeyPath:@"key"];
         [object removeObserver:self forKeyPath:@"value"];
     }];
    
    objects = nil;
}

- (void)refreshWatch
{
    [super refreshWatch];
    
    [self executeDidChangeHandler];
}

#pragma mark - NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
    [self executeDidChangeHandler];
}

@end
