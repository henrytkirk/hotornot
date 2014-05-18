//
//  HKConstants.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Instagram client ID.
 */
extern NSString *const HKInstagramClientID;

/**
 * Instagram secret.
 */
extern NSString *const HKInstagramSecret;

/**
 * Notification for when application will terminate, used for coredata cleanup.
 */
extern NSString *const ApplicationWillTerminateNotification;

/**
 * Enum for voting hot or not.
 */
typedef NS_ENUM(NSInteger, HKInstagramPhotoVote) {
    HKInstagramPhotoVoteHot,
    HKInstagramPhotoVoteNot
};

/**
 * Constants.
 */
@interface HKConstants : NSObject

@end
