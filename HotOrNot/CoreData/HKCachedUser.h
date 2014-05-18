//
//  HKCachedUser.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HKCachedPhoto;

@interface HKCachedUser : NSManagedObject

@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userProfileImageUrl;
@property (nonatomic, retain) NSNumber * hotVotes;
@property (nonatomic, retain) NSNumber * notVotes;
@property (nonatomic, retain) NSSet *photos;
@end

@interface HKCachedUser (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(HKCachedPhoto *)value;
- (void)removePhotosObject:(HKCachedPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
