//
//  HKScoreboardCollectionViewCell.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKScoreboardCollectionViewCell.h"

@interface HKScoreboardCollectionViewCell ()

/**
 * User we're displaying
 */
@property (nonatomic, strong) HKInstagramUser *instagramUser;

/**
 * Imageview of user's profile image
 */
@property (nonatomic, strong) UIImageView *userImageView;

/**
 * Tinted overlay based on how many hot votes
 */
@property (nonatomic, strong) UIView *overlayView;

/**
 * How many hot/not vote count
 */
@property (nonatomic, strong) UILabel *hotVoteCountLabel;

/**
 * Sets up the view
 */
- (void)setupViews;

@end

@implementation HKScoreboardCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)dealloc {
    [self.userImageView cancelImageRequestOperation];
}

- (void)setupViews {
    
    // image view
    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.userImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userImageView.backgroundColor = [UIColor clearColor];
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.userImageView];
    
    // overlay
    self.overlayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlayView.backgroundColor = [UIColor redColor];
    [self addSubview:self.overlayView];

    // vote count
    self.hotVoteCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.hotVoteCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.hotVoteCountLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.hotVoteCountLabel.textColor = [UIColor whiteColor];
    self.hotVoteCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25];
    self.hotVoteCountLabel.adjustsFontSizeToFitWidth = YES;
    self.hotVoteCountLabel.text = @"";
    self.hotVoteCountLabel.textAlignment = NSTextAlignmentCenter;
    self.hotVoteCountLabel.hidden = YES;
    [self addSubview:self.hotVoteCountLabel];

    // Constraints
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_userImageView, _overlayView, _hotVoteCountLabel);
    // constrain all to superview
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_userImageView]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_userImageView]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_overlayView]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_overlayView]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hotVoteCountLabel]|" options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hotVoteCountLabel]|" options:0 metrics:nil views:viewsDict]];

    [self layoutIfNeeded];

}

- (void)prepareForReuse {
    [super prepareForReuse];
    // set image to nil on reuse
    self.userImageView.image = nil;
}

#pragma mark - Setters

- (void)setInstagramUser:(HKInstagramUser *)instagramUser totalUserCount:(NSUInteger)totalUserCount {
    _instagramUser = instagramUser;
    
    // fetch image
    [self.userImageView setImageWithURL:[NSURL URLWithString:instagramUser.userProfileImageUrl] placeholderImage:nil];
    
    // Set overlay view's color/alpha based on how hot
    // this sort of works, but need a lot of votes for it to show
    // if we have hot votes, tint red the more it has, if not
    // tint it black the more not votes it has
    CGFloat votes = instagramUser.hotVotes;
    if (votes > 0) {
        self.overlayView.backgroundColor = [UIColor redColor];
    } else {
        votes = instagramUser.notVotes;
        self.overlayView.backgroundColor = [UIColor blackColor];
    }
    // grab alpha percent, but limit it.
    CGFloat percent = MIN((votes / (CGFloat)totalUserCount) * 2.0, 0.65);
    self.overlayView.alpha = percent;
    
    // set votecount
    self.hotVoteCountLabel.text = [NSString stringWithFormat:@"%li/%li", (long)instagramUser.hotVotes, (long)instagramUser.notVotes];
    
    [self layoutIfNeeded];
}

#pragma mark - Vote count

- (void)showVoteCountLabel:(BOOL)show {
    // show vote count label or not
    self.hotVoteCountLabel.hidden = !show;
}

@end
