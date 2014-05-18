//
//  HKPhotoView.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKPhotoView.h"
#import "UIImage+ImageEffects.h"

@interface HKPhotoView ()

/**
 * Image view that displays the selfie
 */
@property (nonatomic, strong) UIImageView *photoImageView;

/**
 * Overlay we put on top when you tap on it
 */
@property (nonatomic, strong) UIImageView *overlayImageView;

/**
 * Original image so we can reset the overlay
 */
@property (nonatomic, strong) UIImage *originalImage;

/**
 * Sets up the view
 */
- (void)setupView;

/**
 * Custom setter that handles setting image
 */
- (void)setInstagramPhoto:(HKInstagramPhoto *)instagramPhoto;

/**
 * Called when user taps on view to vote
 */
- (void)handleUserTap:(UITapGestureRecognizer *)recognizer;

@end

@implementation HKPhotoView

- (instancetype)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    // cancel any pending image fetching
    [self.photoImageView cancelImageRequestOperation];
}

- (void)setupView {
    
    // basic setup
    self.backgroundColor = [UIColor clearColor];
    
    // Gesture for photo
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    // photo
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.photoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoImageView.backgroundColor = [UIColor clearColor];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.photoImageView];
    
    // overlay that has a heart in it
    self.overlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.overlayImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlayImageView.backgroundColor = [UIColor clearColor];
    self.overlayImageView.contentMode = UIViewContentModeCenter;
    self.overlayImageView.hidden = YES;
    self.overlayImageView.image = [UIImage imageNamed:@"heart"];
    [self addSubview:self.overlayImageView];
    
    // Constraints
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_photoImageView, _overlayImageView);
    
    // constrain all views to superview
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_photoImageView]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_photoImageView]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_overlayImageView]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_overlayImageView]|" options:0 metrics:nil views:viewsDict]];

    [self layoutIfNeeded];
    
}

#pragma mark - Setters

- (void)setInstagramPhoto:(HKInstagramPhoto *)instagramPhoto {
    _instagramPhoto = instagramPhoto;
    
    // set overlay to hidden
    self.overlayImageView.hidden = YES;
    // remove old image
    self.photoImageView.image = nil;
    // Download image
    NSURL *photoUrl = [NSURL URLWithString:self.instagramPhoto.standardResolutionImageUrl];
    [self.photoImageView setImageWithURL:photoUrl placeholderImage:nil];
}

#pragma mark - Gesture recognizer

- (void)handleUserTap:(UITapGestureRecognizer *)recognizer {

    // show heart with effect
    UIImage *blurredImage = [self.photoImageView.image applyTintEffectWithColor:[[UIColor redColor] colorWithAlphaComponent:0.25]];
    if (!self.originalImage) {
        self.originalImage = self.photoImageView.image;
    }
    // blur current image
    self.photoImageView.image = blurredImage;
    // show overlay
    self.overlayImageView.hidden = NO;
    
    // Call delegate and reset after a bit
    CGFloat delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([self.delegate respondsToSelector:@selector(userDidTapOnPhotoView:)]) {
            [self.delegate userDidTapOnPhotoView:self];
        }
        // reset
        self.overlayImageView.hidden = YES;
        self.photoImageView.image = self.originalImage;
    });
}

@end
