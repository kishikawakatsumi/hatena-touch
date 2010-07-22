//
//  HatenaTouchAppDelegate.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright Kishikawa Katsumi 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface HatenaTouchAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

