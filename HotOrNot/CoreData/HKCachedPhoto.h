//
//  HKCachedPhoto.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HKCachedUser;

@interface HKCachedPhoto : NSManagedObject

@property (nonatomic, retain) NSNumber * locationLatitude;
@property (nonatomic, retain) NSNumber * locationLongitude;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * standardResolutionImageUrl;
@property (nonatomic, retain) NSString * thumbnailImageUrl;
@property (nonatomic, retain) HKCachedUser *user;

@end
