//
//  HKScoreboardCollectionViewCell.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Cell that shows a user's profile image and the number of votes they have
 * accumulated. It also will tint the cell a bit red based on number of votes.
 */
@interface HKScoreboardCollectionViewCell : UICollectionViewCell

/**
 * Sets the user to display and total count of users to decorate cell
 */
- (void)setInstagramUser:(HKInstagramUser *)instagramUser totalUserCount:(NSUInteger)totalUserCount;

/**
 * Boolean to show vote count label or not
 */
- (void)showVoteCountLabel:(BOOL)show;

@end
