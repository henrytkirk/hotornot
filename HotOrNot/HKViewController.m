//
//  HKViewController.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKViewController.h"
#import "HKRatingViewController.h"
#import "HKScoreBoardViewController.h"

@interface HKViewController ()

/**
 * Title label.
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 * Button for starting a rating session.
 */
@property (nonatomic, strong) UIButton *startRatingButton;

/**
 * Button for showing scoreboard.
 */
@property (nonatomic, strong) UIButton *scoreBoardButton;

/**
 * Called when user taps on start rating button.
 */
- (void)userDidTapStartRatingButton:(id)sender;

/**
 * Called when user taps on scoreboard button.
 */
- (void)userDidTapScoreboardButton:(id)sender;

@end

@implementation HKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // basic setup
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    // title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35];
    self.titleLabel.text = @"Hot or Not";
    [self.view addSubview:self.titleLabel];

    // start rating button
    self.startRatingButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.startRatingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.startRatingButton setTitle:@"Rate some selfies" forState:UIControlStateNormal];
    self.startRatingButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    [self.startRatingButton addTarget:self action:@selector(userDidTapStartRatingButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startRatingButton];

    // scoreboard button
    self.scoreBoardButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.scoreBoardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scoreBoardButton setTitle:@"See who's hot" forState:UIControlStateNormal];
    self.scoreBoardButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    [self.scoreBoardButton addTarget:self action:@selector(userDidTapScoreboardButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scoreBoardButton];

    // Constraints
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_startRatingButton, _scoreBoardButton, _titleLabel);

    // constrain all horizontally to superview with default spacing
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleLabel]-|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_startRatingButton]-|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_scoreBoardButton]-|" options:0 metrics:nil views:viewsDict]];
    // constrain all vertically with some padding
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[_titleLabel]-44-[_startRatingButton]-44-[_scoreBoardButton]" options:0 metrics:nil views:viewsDict]];

    [self.view layoutIfNeeded];
}

#pragma mark - Button actions

- (void)userDidTapStartRatingButton:(id)sender {
    // show rating view
    HKRatingViewController *ratingViewController = [[HKRatingViewController alloc] init];
    [self presentViewController:ratingViewController animated:YES completion:nil];
}

- (void)userDidTapScoreboardButton:(id)sender {
    // show score board
    HKScoreBoardViewController *scoreboardViewController = [[HKScoreBoardViewController alloc] init];
    [self presentViewController:scoreboardViewController animated:YES completion:nil];
}

@end
