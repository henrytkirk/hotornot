//
//  HKCoreDataManager.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKCoreDataManager.h"
#import "HKCachedPhoto.h"
#import "HKCachedUser.h"

/**
 * Entity name constants
 */
static NSString *HKCachedPhotoEntityName = @"HKPhoto";
static NSString *HKCachedUserEntityName = @"HKUser";

@interface HKCoreDataManager ()

/**
 * Private queue managed object context that handles all save actions. It is
 * independant to the mainQueue context.
 */
@property (nonatomic, strong) NSManagedObjectContext *backgroundObjectContext;

/**
 * Main queue managed object context that handles all fetch actions. It is
 * not set as parent to background context. It listens to changes in background and updates.
 */
@property (nonatomic, strong) NSManagedObjectContext *mainQueueObjectContext;

/**
 * Managed object model
 */
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

/**
 * Persistent store which is shared between contexts
 */
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Scoreboard fetched results controller
 */
@property (nonatomic, strong) NSFetchedResultsController *scoreboardFetchedResultsController;

/**
 * Handles background save notifications to merge into main context
 */
- (void)backgroundContextDidSaveNotification:(NSNotification *)notification;

/**
 * Creates new cached user
 */
- (HKCachedUser *)createCachedUser:(HKInstagramUser *)user;

@end

@implementation HKCoreDataManager

#pragma mark Init

- (id)init {
    if ((self = [super init])) {
        // setup stack
        [self setupStack];
        
        // For when application terminates, save any outstanding coreData changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContexts) name:ApplicationWillTerminateNotification object:nil];
        // background save
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:self.backgroundObjectContext];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Set Vote

- (void)setVote:(HKInstagramPhotoVote)vote forPhoto:(HKInstagramPhoto *)photo {
    
    // if user exists, update, if not create and save
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %i", photo.user.userId];
    NSEntityDescription *entity = [NSEntityDescription entityForName:HKCachedUserEntityName inManagedObjectContext:self.backgroundObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    HKCachedUser *cachedUser;
    NSArray *fetchedObjects = [self.backgroundObjectContext executeFetchRequest:request error:&error];
    if (fetchedObjects.count == 1) {
        // we have user
        cachedUser = [fetchedObjects firstObject];
    } else {
        // Create cached user
        cachedUser = [self createCachedUser:photo.user];
    }
    
    // set vote
    switch (vote) {
        case HKInstagramPhotoVoteHot:
            cachedUser.hotVotes = @(cachedUser.hotVotes.integerValue + 1);
            break;
        case HKInstagramPhotoVoteNot:
            cachedUser.notVotes = @(cachedUser.notVotes.integerValue + 1);
        default:
            break;
    }
    
    // save to background since all saves are done there.
    if (![self.backgroundObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", error);
    }
}

#pragma mark - Create

- (HKCachedUser *)createCachedUser:(HKInstagramUser *)user {

    // create user, all additions are done on background context
    HKCachedUser *cachedUser = [NSEntityDescription insertNewObjectForEntityForName:HKCachedUserEntityName inManagedObjectContext:self.backgroundObjectContext];
    cachedUser.userId = @(user.userId);
    cachedUser.userName = user.userName;
    cachedUser.userProfileImageUrl = user.userProfileImageUrl;
    
    return cachedUser;
}

#pragma mark - Save

- (void)saveContexts {
    NSError *error;
    if (![self.backgroundObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", error);
    }
}

#pragma mark - FetchedResultsController

- (void)resetFetchedResultsController {
    self.scoreboardFetchedResultsController = nil;
}

- (NSFetchedResultsController *)scoreboardFetchedResultsControllerWithDelegate:(id<NSFetchedResultsControllerDelegate>)delegate {
    
    if (_scoreboardFetchedResultsController != nil) {
        return _scoreboardFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HKUser" inManagedObjectContext:self.mainQueueObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hotVotes" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.mainQueueObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = delegate;
    self.scoreboardFetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.scoreboardFetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching %@, %@", error, [error userInfo]);
    }
    
    return _scoreboardFetchedResultsController;
}

#pragma mark - Core Data stack

- (void)setupStack {
    
    // Get persistent store coordinator
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    // Setup master managed object
    self.backgroundObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.backgroundObjectContext setPersistentStoreCoordinator:coordinator];
    
    self.mainQueueObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainQueueObjectContext setPersistentStoreCoordinator:coordinator];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HotOrNotModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *storePath = [documentsPath stringByAppendingPathComponent:@"HotOrNotModel.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Log error and kill app
        NSLog(@"Error loading persistent store %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - NSManagedObjectContextDidSaveNotification

- (void)backgroundContextDidSaveNotification:(NSNotification *)notification {
    
    // Make sure we're only merging background context info
    if (notification.object == self.backgroundObjectContext) {
        if ([NSThread isMainThread]) {
            if (notification.object != self.mainQueueObjectContext) {
                [self.mainQueueObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                [self.mainQueueObjectContext mergeChangesFromContextDidSaveNotification:notification];
                NSError *error;
                if (![self.mainQueueObjectContext save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", error);
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self backgroundContextDidSaveNotification:notification];
            });
        }
    }
}

@end
