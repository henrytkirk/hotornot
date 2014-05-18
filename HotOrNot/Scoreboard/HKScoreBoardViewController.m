//
//  HKScoreBoardViewController.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKScoreBoardViewController.h"
#import "HKScoreboardCollectionViewCell.h"
#import "HKCoreDataManager.h"

// Cell Identifiers
static NSString *HKScoreBoardCollectionViewCellIdentifier = @"HKScoreBoardCollectionViewCellIdentifier";

@interface HKScoreBoardViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

/**
 * Button to close view
 */
@property (nonatomic, strong) UIButton *closeButton;

/**
 * Title label
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 * Collectionview that shows you saved votes
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 * Injected CoreDataManager
 */
@property (nonatomic, strong) HKCoreDataManager *coreDataManager;

/**
 * Called when user taps on close button
 */
- (void)userDidTapCloseButton:(id)sender;

/**
 * Decorates the cell or not during scrolling to show vote counts
 */
- (void)showCellVoteCount:(BOOL)showVoteCount;

@end

@implementation HKScoreBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // basic setup
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // Inject properties
    [[TyphoonComponentFactory defaultFactory] injectProperties:self];

    // setup collectionview
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.view addSubview:self.collectionView];
    
    // set flow layout attributes
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds)/4, CGRectGetWidth(self.view.bounds)/4);
    
    // Register cell
    [self.collectionView registerClass:[HKScoreboardCollectionViewCell class] forCellWithReuseIdentifier:HKScoreBoardCollectionViewCellIdentifier];
    
    // close button
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(userDidTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];

    // title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    self.titleLabel.text = @"This is who's hot";
    [self.view addSubview:self.titleLabel];
    
    // Constraints
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_closeButton, _collectionView, _titleLabel);

    // constrain button
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_closeButton(44)]" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_closeButton(44)]" options:0 metrics:nil views:viewsDict]];
    // collection view to superview
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:viewsDict]];
    // center title label and constrain to top
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[_titleLabel]" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // reload data
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.coreDataManager resetFetchedResultsController];
}

- (void)userDidTapCloseButton:(id)sender {
    // close
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSFetchedResultsController *controller = [self.coreDataManager scoreboardFetchedResultsControllerWithDelegate:self];
    return controller.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSFetchedResultsController *controller = [self.coreDataManager scoreboardFetchedResultsControllerWithDelegate:self];
    return [controller.sections[section] numberOfObjects];
}

#pragma mark - UICollectionView Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get our object
    NSFetchedResultsController *controller = [self.coreDataManager scoreboardFetchedResultsControllerWithDelegate:self];
    HKInstagramUser *instagramUser = [[HKInstagramUser alloc] initWithCachedUser:[controller objectAtIndexPath:indexPath]];
    
    // get cell
    HKScoreboardCollectionViewCell *cell = (HKScoreboardCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:HKScoreBoardCollectionViewCellIdentifier forIndexPath:indexPath];

    // setup cell
    [cell setInstagramUser:instagramUser totalUserCount:[collectionView numberOfItemsInSection:indexPath.section]];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate (from CollectionView) 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self showCellVoteCount:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [self showCellVoteCount:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self showCellVoteCount:NO];
}

#pragma mark - Cell Decoration

- (void)showCellVoteCount:(BOOL)showVoteCount {
    
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = (NSIndexPath *)obj;
        HKScoreboardCollectionViewCell *cell = (HKScoreboardCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell showVoteCountLabel:showVoteCount];
    }];
}

@end
