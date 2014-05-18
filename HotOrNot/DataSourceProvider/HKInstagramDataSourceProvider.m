//
//  HKInstagramDataSourceProvider.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKInstagramDataSourceProvider.h"

@interface  HKInstagramDataSourceProvider ()

/**
 * Data array to hold photo objects
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

/**
 * Next url from instagram api - url to fetch next batch of selfies.
 */
@property (nonatomic, strong) NSURL *nextUrl;

/**
 * Count of records processed, when hits 80% of maximum, fetches more selfies.
 */
@property (nonatomic) NSInteger recordCount;

/**
 * Processes the retrieved data from the API.
 */
- (void)processRetrievedData:(NSArray *)dataArray;

@end

@implementation HKInstagramDataSourceProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self cancelNetworkRequest];
}

- (NSInteger)numberOfItems {
    return self.dataArray.count;
}

- (HKInstagramPhoto *)recordForItemAtIndex:(NSInteger)index {
    return self.dataArray[index];
}

- (HKInstagramPhoto *)randomRecord {
    // Get random
    int randomIndex = arc4random_uniform((int)self.dataArray.count - 1);
    HKInstagramPhoto *photo = self.dataArray[randomIndex];
    self.recordCount++;
    if ((self.recordCount / self.dataArray.count) >= .8) {
        [self loadDataFromNetwork];
    }
    // Reset if too high
    if (self.recordCount > self.dataArray.count-1) {
        self.recordCount = 0;
    }
    return photo;
}

- (void)loadDataFromNetwork {
    
    NSURL *url = self.nextUrl;
    if (!url) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/selfie/media/recent?client_id=%@", HKInstagramClientID]];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *responseDict = (NSDictionary *)responseObject;
        // set next url
        self.nextUrl = [NSURL URLWithString:responseDict[@"pagination"][@"next_url"]];
        // Process data
        [self processRetrievedData:responseDict[@"data"]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // error, notify delegate
        if ([self.delegate respondsToSelector:@selector(didFinishFetchingNetworkDataWithError:)]) {
            [self.delegate didFinishFetchingNetworkDataWithError:error];
        }
    }];
}

- (void)reloadDataFromNetwork {
    self.nextUrl = nil;
    self.recordCount = 0;
    [self.dataArray removeAllObjects];
    [self loadDataFromNetwork];
}

- (void)cancelNetworkRequest {
    // cancel all operations
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
}

- (void)processRetrievedData:(NSArray *)dataArray {
    
    // loop our data and save if needed
    [dataArray enumerateObjectsUsingBlock:^(NSDictionary *dataDict, NSUInteger idx, BOOL *stop) {
        // save if it's an image
        if ([dataDict[@"type"] isEqualToString:@"image"]) {
            // creat object
            HKInstagramPhoto *instagramPhoto = [[HKInstagramPhoto alloc] initWithRemoteDictionary:dataDict];
            [self.dataArray addObject:instagramPhoto];
        }
    }];
    
    // Notify delegate
    if ([self.delegate respondsToSelector:@selector(didFinishFetchingNetworkData)]) {
        [self.delegate didFinishFetchingNetworkData];
    }

}

@end
