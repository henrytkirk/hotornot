//
//  HKInstagramPhoto.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKCachedPhoto;

/**
 * Object that stores instagram info from both webservice and cached in coredata
 * Note: This is not saved to coredata yet, ran out of time.
 */
@interface HKInstagramPhoto : NSObject

/**
 * Readonly, Photo ID
 */
@property (readonly, nonatomic, strong) NSString *photoId;

/**
 * Readonly, Thumbnail image url, really low res since size is smaller than needed.
 */
@property (readonly, nonatomic, strong) NSString *thumbnailImageUrl;

/**
 * Readonly, Standard resolution image url
 */
@property (readonly, nonatomic, strong) NSString *standardResolutionImageUrl;

/**
 * Readonyl, Coordinate where photo was taken
 */
@property (readonly, nonatomic) CLLocationCoordinate2D locationCoordinate;

/**
 * Readonly, User associated with the photo
 */
@property (readonly, nonatomic, strong) HKInstagramUser *user;

/**
 * Creates object from remote dictionary
 */
- (instancetype)initWithRemoteDictionary:(NSDictionary *)remoteDictionary;

/**
 * Creates object from cached photo (not yet implemented)
 */
- (instancetype)initWithCachedPhoto:(HKCachedPhoto *)cachedPhoto;

@end
