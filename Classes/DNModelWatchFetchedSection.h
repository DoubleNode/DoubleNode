//
//  DNModelWatchFetchedSection.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>

@interface DNModelWatchFetchedSection : NSObject <NSFetchedResultsSectionInfo>

/* Name of the section
 */
@property (nonatomic, copy)         NSString*   name;

/* Title of the section (used when displaying the index)
 */
@property (nonatomic, retain)       NSString*   indexTitle;

/* Number of objects in section
 */
@property (nonatomic, readwrite)    NSUInteger  numberOfObjects;

/* Returns the array of objects in the section.
 */
@property (nonatomic, retain)       NSArray*    objects;

@end

