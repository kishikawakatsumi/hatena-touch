//
//  HatenaTouchAppDelegate.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright Kishikawa Katsumi 2010. All rights reserved.
//

#import "HatenaTouchAppDelegate.h"
#import "RootViewController.h"
#import "UserSettings.h"

@implementation HatenaTouchAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [UserSettings saveSettings];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [UserSettings saveSettings];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}

@end
