//
//  HKInstagramPhoto.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKInstagramPhoto.h"
#import "HKCachedPhoto.h"

@interface HKInstagramPhoto ()

/**
 * Photo ID
 */
@property (nonatomic, strong) NSString *photoId;

/**
 * Thumbnail image url, really low res since size is smaller than needed.
 */
@property (nonatomic, strong) NSString *thumbnailImageUrl;

/**
 * Standard resolution image url
 */
@property (nonatomic, strong) NSString *standardResolutionImageUrl;

/**
 * Coordinate where photo was taken
 */
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

/**
 * User associated with the photo
 */
@property (nonatomic, strong) HKInstagramUser *user;

/**
 * Processes the remote dictionary from instagram api
 */
- (void)processRemoteDictionary:(NSDictionary *)remoteDictionary;

/**
 * Processes the cached photo from core data (not yet fully implemented)
 */
- (void)processCachedPhoto:(HKCachedPhoto *)cachedPhoto;

@end

@implementation HKInstagramPhoto

- (instancetype)initWithCachedPhoto:(HKCachedPhoto *)cachedPhoto {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithRemoteDictionary:(NSDictionary *)remoteDictionary {
    self = [super init];
    if (self) {
        [self processRemoteDictionary:remoteDictionary];
    }
    return self;
}

- (void)processRemoteDictionary:(NSDictionary *)remoteDictionary {
    
    self.photoId = remoteDictionary[@"id"];
    self.thumbnailImageUrl = remoteDictionary[@"images"][@"low_resolution"][@"url"];
    self.standardResolutionImageUrl = remoteDictionary[@"images"][@"standard_resolution"][@"url"];
    if (![remoteDictionary[@"location"] isEqual:[NSNull null]]) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([remoteDictionary[@"location"][@"latitude"] doubleValue], [remoteDictionary[@"location"][@"longitude"] doubleValue]);
        self.locationCoordinate = coordinate;
    }
    self.user = [[HKInstagramUser alloc] initWithRemoteDictionary:remoteDictionary[@"user"]];
}

- (void)processCachedPhoto:(HKCachedPhoto *)cachedPhoto {
    
    self.photoId = cachedPhoto.photoId;
    self.thumbnailImageUrl = cachedPhoto.thumbnailImageUrl;
    self.standardResolutionImageUrl = cachedPhoto.standardResolutionImageUrl;
    self.locationCoordinate = CLLocationCoordinate2DMake(cachedPhoto.locationLatitude.doubleValue, cachedPhoto.locationLongitude.doubleValue);
    self.user = [[HKInstagramUser alloc] initWithCachedUser:cachedPhoto.user];
    
}

@end
