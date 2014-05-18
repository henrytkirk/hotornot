//
//  HKInstagramUser.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKInstagramUser.h"
#import "HKCachedUser.h"
#import "HKCoreDataManager.h"

@interface HKInstagramUser ()

/**
 * UserId
 */
@property (nonatomic) NSInteger userId;

/**
 * Fullname of user
 */
@property (nonatomic, strong) NSString *fullName;

/**
 * Username of user
 */
@property (nonatomic, strong) NSString *userName;

/**
 * user profile image url
 */
@property (nonatomic, strong) NSString *userProfileImageUrl;

/**
 * How many hot votes
 */
@property (nonatomic) NSInteger hotVotes;

/**
 * How many not votes
 */
@property (nonatomic) NSInteger notVotes;

/**
 * Injected CoreDataManager
 */
@property (nonatomic, strong) HKCoreDataManager *coreDataManager;

/**
 * Process the remote dictionary from instagram api
 */
- (void)processRemoteDictionary:(NSDictionary *)remoteDictionary;

/**
 * Process from cached user from core data
 */
- (void)processCachedUser:(HKCachedUser *)cachedUser;

@end

@implementation HKInstagramUser

- (instancetype)initWithCachedUser:(HKCachedUser *)cachedUser {
    self = [super init];
    if (self) {
        [self processCachedUser:cachedUser];
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
    
    self.userId = [remoteDictionary[@"id"] integerValue];
    self.fullName = remoteDictionary[@"full_name"];
    self.userName = remoteDictionary[@"username"];
    self.userProfileImageUrl = remoteDictionary[@"profile_picture"];
}

- (void)processCachedUser:(HKCachedUser *)cachedUser {
    
    self.userId = cachedUser.userId.integerValue;
    self.fullName = cachedUser.fullName;
    self.userName = cachedUser.userName;
    self.userProfileImageUrl = cachedUser.userProfileImageUrl;
    self.hotVotes = cachedUser.hotVotes.integerValue;
    self.notVotes = cachedUser.notVotes.integerValue;

}

@end
