//
//  HKInstagramUser.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKCachedUser;

/**
 * Object that stores instagram info from api or core data if it's cached
 */
@interface HKInstagramUser : NSObject

/**
 * Readonly, UserId
 */
@property (readonly, nonatomic) NSInteger userId;

/**
 * Readonly, Fullname of user
 */
@property (readonly, nonatomic, strong) NSString *fullName;

/**
 * Readonly, Username of user
 */
@property (readonly, nonatomic, strong) NSString *userName;

/**
 * Readonly, user profile image url
 */
@property (readonly, nonatomic, strong) NSString *userProfileImageUrl;

/**
 * Readonly, how many hot votes
 */
@property (readonly, nonatomic) NSInteger hotVotes;

/**
 * Readonly, how many not votes
 */
@property (readonly, nonatomic) NSInteger notVotes;

/**
 * Init with remote data from instagram api
 */
- (instancetype)initWithRemoteDictionary:(NSDictionary *)remoteDictionary;

/**
 * Init with cached user from core data
 */
- (instancetype)initWithCachedUser:(HKCachedUser *)cachedUser;

@end
