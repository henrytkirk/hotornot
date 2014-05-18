//
//  HKRatingViewController.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKRatingViewController.h"
#import "HKInstagramDataSourceProvider.h"
#import "HKPhotoView.h"
#import "HKCoreDataManager.h"

@interface HKRatingViewController () <HKInstagramDataSourceProviderDelegate, HKPhotoViewDelegate, UIDynamicAnimatorDelegate>

/**
 * Datasource provider for fetching from instagram API.
 */
@property (nonatomic, strong) HKInstagramDataSourceProvider *dataSourceProvider;

/**
 * Loading indicator when fetching
 */
@property (nonatomic, strong) UIActivityIndicatorView *activitySpinner;

/**
 * Close button
 */
@property (nonatomic, strong) UIButton *closeButton;

/**
 * Title label of view
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 * Tells user what to do
 */
@property (nonatomic, strong) UILabel *directionsLabel;

/**
 * Top photo for user to select from
 */
@property (nonatomic, strong) HKPhotoView *photoOne;

/**
 * Bottom photo for user to select from
 */
@property (nonatomic, strong) HKPhotoView *photoTwo;

/**
 * Copy of photo that's not hot that we'll throw away. We do this 
 * because constraints don't work well in some situations w/ UIKit dynamics
 */
@property (nonatomic, strong) UIView *snappingView;

/**
 * Is this first launch or not
 */
@property (nonatomic, getter = isFirstLaunch) BOOL firstLaunch;

/**
 * UIKit dynamics animator for selfies
 */
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

/**
 * Injected CoreDataManager
 */
@property (nonatomic, strong) HKCoreDataManager *coreDataManager;

/**
 * Called when user taps on close button
 */
- (void)userDidTapCloseButton:(id)sender;

/**
 * Loads next photo for user to vote on
 */
- (void)nextPhoto:(HKPhotoView *)photoView;

@end

@implementation HKRatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstLaunch = YES;
    
    // Inject properties
    [[TyphoonComponentFactory defaultFactory] injectProperties:self];

    // set delegate
    self.dataSourceProvider.delegate = self;

    // basic setup
    self.view.backgroundColor = [UIColor grayColor];

    // create the animator
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.dynamicAnimator.delegate = self;
    
    // Setup activity
    self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activitySpinner.translatesAutoresizingMaskIntoConstraints = NO;
    self.activitySpinner.hidesWhenStopped = YES;
    [self.view addSubview:self.activitySpinner];
    
    // Constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activitySpinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activitySpinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(userDidTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    // title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    self.titleLabel.text = @"Who's hotter?";
    [self.view addSubview:self.titleLabel];
    
    // directions label
    self.directionsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.directionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.directionsLabel.backgroundColor = [UIColor clearColor];
    self.directionsLabel.textColor = [UIColor whiteColor];
    self.directionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    self.directionsLabel.text = @"Tap the photo of who's hotter";
    [self.view addSubview:self.directionsLabel];
    
    // photos
    self.photoOne = [[HKPhotoView alloc] initWithFrame:CGRectZero];
    self.photoTwo = [[HKPhotoView alloc] initWithFrame:CGRectZero];
    self.photoOne.delegate = self;
    self.photoTwo.delegate = self;
    self.photoOne.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoTwo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.photoOne];
    [self.view addSubview:self.photoTwo];
    
    // make sure photos are equal height based on area to fit them (thus to support
    // both iphone sizes and rotation)
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoOne attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoTwo attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];

    // Constraints
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_closeButton, _titleLabel, _directionsLabel, _photoOne, _photoTwo);
    
    // constrain button
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_closeButton(44)]" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_closeButton(44)]" options:0 metrics:nil views:viewsDict]];
    // constrain photos
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_photoOne]-|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_photoTwo]-|" options:0 metrics:nil views:viewsDict]];
    // constrain everything vertically
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[_titleLabel]-4-[_directionsLabel]-20-[_photoOne]-20-[_photoTwo]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDict]];
    // center title label
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // start animating and fetch from network
    [self.activitySpinner startAnimating];
    [self.dataSourceProvider loadDataFromNetwork];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // cleanup
    [self.dataSourceProvider cancelNetworkRequest];
}

#pragma mark - Button Actions

- (void)userDidTapCloseButton:(id)sender {
    // close view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HKInstagramDataSourceProviderDelegate

- (void)didFinishFetchingNetworkData {
    
    if ([NSThread isMainThread]) {
        // stop spinner
        [self.activitySpinner stopAnimating];
        // if we're on first launch, refresh both photos
        if (self.isFirstLaunch) {
            // First batch
            [self nextPhoto:self.photoOne];
            [self nextPhoto:self.photoTwo];
            self.firstLaunch = NO;
        }
    } else {
        [self didFinishFetchingNetworkData];
    }
}

- (void)didFinishFetchingNetworkDataWithError:(NSError *)error {
    // stop spinning
    [self.activitySpinner stopAnimating];
    // show alert error
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred. Check internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Photos

- (void)nextPhoto:(HKPhotoView *)photoView {
    
    // Load next photo
    HKInstagramPhoto *nextPhoto = [self.dataSourceProvider randomRecord];
    [photoView setInstagramPhoto:nextPhoto];
    photoView.hidden = NO;
}

#pragma mark - HKPhotoViewDelegate

- (void)userDidTapOnPhotoView:(HKPhotoView *)photoView {
    
    HKPhotoView *refreshview;
    CGFloat offscreenX;
    // Determine which photo we need to remove and refresh
    // also set direction to make it a little more interesting
    if ([photoView isEqual:self.photoOne]) {
        refreshview = self.photoTwo;
        offscreenX = (CGRectGetWidth(self.view.bounds) + CGRectGetWidth(refreshview.frame)/2);
    } else {
        refreshview = self.photoOne;
        offscreenX = -CGRectGetWidth(self.view.bounds)/2;
    }
    
    // set votes
    [self.coreDataManager setVote:HKInstagramPhotoVoteHot forPhoto:photoView.instagramPhoto];
    [self.coreDataManager setVote:HKInstagramPhotoVoteNot forPhoto:refreshview.instagramPhoto];
    
    // Take screen shot so we can animate it off
    self.snappingView = [refreshview snapshotViewAfterScreenUpdates:YES];
    // put the snap view over view we're going to refresh
    self.snappingView.frame = refreshview.frame;
    self.snappingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.snappingView];
    // set view we're freshing to hidden
    refreshview.hidden = YES;
    
    // Snap offscreen
    CGPoint offscreenPoint = CGPointMake(offscreenX, CGRectGetMidY(refreshview.frame));
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self.snappingView snapToPoint:offscreenPoint];
    snapBehavior.damping = 0.1;
    [self.dynamicAnimator addBehavior:snapBehavior];
    
    // Refresh after a bit
    CGFloat delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self nextPhoto:refreshview];
    });
}

#pragma mark UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {

    // Remove animators, and remove snapping view
    [animator removeAllBehaviors];
    [self.snappingView removeFromSuperview];
}

@end
