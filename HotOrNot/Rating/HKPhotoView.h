//
//  HKPhotoView.h
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HKPhotoView;

/**
 * Delegate for when user taps on a photo
 */
@protocol HKPhotoViewDelegate <NSObject>

/**
 * Called when user taps photo, vote is hot
 */
- (void)userDidTapOnPhotoView:(HKPhotoView *)photoView;

@end

/**
 * View that displays the photo to user for them to vote on. Tapping on the
 * view will put a vote of hot onto it.
 */
@interface HKPhotoView : UIView

/**
 * Instagram photo object we're displaying
 */
@property (nonatomic, strong) HKInstagramPhoto *instagramPhoto;

/**
 * Delegate
 */
@property (nonatomic, weak) id<HKPhotoViewDelegate>delegate;

@end
