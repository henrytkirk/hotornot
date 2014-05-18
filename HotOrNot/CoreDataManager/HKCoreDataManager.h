//
//  HKCoreDataManager.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Core data manager for saving votes
 */
@interface HKCoreDataManager : NSObject

/**
 * Fetched results controller for score board
 */
- (NSFetchedResultsController *)scoreboardFetchedResultsControllerWithDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;

/**
 * Resets the fetched results controller for score board
 */
- (void)resetFetchedResultsController;

/**
 * Save vote to core data
 */
- (void)setVote:(HKInstagramPhotoVote)vote forPhoto:(HKInstagramPhoto *)photo;

@end
