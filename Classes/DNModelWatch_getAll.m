//
//  DNModelWatch_getAll.m
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNModelWatch_getAll.h"

@interface DNModelWatch_getAll () <NSFetchedResultsControllerDelegate>
{
    NSFetchRequest*             fetchRequest;
    NSFetchedResultsController* fetchResultsController;
    
    getAll_resultsHandlerBlock  resultsHandler;
}

@end

@implementation DNModelWatch_getAll

+ (id)watchWithFetch:(NSFetchRequest*)fetch
          andHandler:(getAll_resultsHandlerBlock)resultsHandler
{
    return [[DNModelWatch_getAll alloc] initWithFetch:fetch andHandler:resultsHandler];
}

- (id)initWithFetch:(NSFetchRequest*)fetch
         andHandler:(getAll_resultsHandlerBlock)handler
{
    self = [super init];
    if (self)
    {
        fetchRequest    = fetch;
        resultsHandler  = handler;
        
        fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
                                                                     managedObjectContext:[[DNUtilities appDelegate] managedObjectContext]
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
        fetchResultsController.delegate = self;
        [self performFetch:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)performFetch:(NSError **)error
{
    [super performFetch:error];
    
    fetchResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [fetchResultsController performFetch:error];
}

- (void)executeResultsHandler:(NSArray*)entities
{
    resultsHandler(self, entities);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self executeResultsHandler:controller.fetchedObjects];
}

@end
