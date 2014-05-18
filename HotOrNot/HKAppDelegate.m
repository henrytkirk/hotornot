//
//  HKAppDelegate.m
//  HotOrNot
//
//  Created by Henry T Kirk on 5/17/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "HKAppDelegate.h"
#import "HKViewController.h"

@interface HKAppDelegate ()

/**
 * Root view controller with menu.
 */
@property (nonatomic, strong) HKViewController *rootViewController;

/**
 * Loads Typhoon assemblies
 */
- (void)loadTyphoonFactory;

@end

@implementation HKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Load Typhoon Assemblies
    [self loadTyphoonFactory];

    // Create window and add root view to it
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootViewController = [[HKViewController alloc] init];
    self.rootViewController.view.frame = self.window.bounds;
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // save any unsaved coredata entries
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationWillTerminateNotification object:nil];
}

#pragma mark - Typhoon Methods

- (void)loadTyphoonFactory {
    
    TyphoonComponentFactory* factory = ([[TyphoonXmlComponentFactory alloc] initWithConfigFileNames:@"CoreComponents.xml", @"ViewControllers.xml", nil]);
    
    [factory makeDefault];
}

@end
