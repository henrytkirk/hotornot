//
//  HKInstagramDataSourceProvider.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Delegate for network completion/failure
 */
@protocol HKInstagramDataSourceProviderDelegate <NSObject>

- (void)didFinishFetchingNetworkData;
- (void)didFinishFetchingNetworkDataWithError:(NSError *)error;

@end

/**
 * Datasource provider that connects to instagram API and retrieves 
 * photos based on #selfie hashtag.
 */
@interface HKInstagramDataSourceProvider : NSObject

/**
 * Delegate
 */
@property (nonatomic, weak) id<HKInstagramDataSourceProviderDelegate>delegate;

/**
 * Number of items available
 */
- (NSInteger)numberOfItems;

/**
 * Record for specific item at index passed
 */
- (HKInstagramPhoto *)recordForItemAtIndex:(NSInteger)index;

/**
 * Returns a random record
 */
- (HKInstagramPhoto *)randomRecord;

/**
 * Fetches data from network, uses next_url if available to fetch additional data
 */
- (void)loadDataFromNetwork;

/**
 * Refreshes all local data and fetches fresh.
 */
- (void)reloadDataFromNetwork;

/**
 * Cancels any current/pending requests
 */
- (void)cancelNetworkRequest;

@end
