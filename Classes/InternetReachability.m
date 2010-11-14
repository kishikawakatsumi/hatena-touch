//
//  InternetReachability.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/22.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "InternetReachability.h"

static InternetReachability *sharedInstance;

@implementation InternetReachability

+ (InternetReachability *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[InternetReachability alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        internetReach = [[Reachability reachabilityForInternetConnection] retain];
        [internetReach startNotifier];
    }
    return self;
}

- (void)dealloc {
    [internetReach release];
    [super dealloc];
}

- (void)reachabilityChanged:(NSNotification *)note {
	Reachability *reachability = [note object];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    if (netStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                                        message:NSLocalizedString(@"No internet connection.", nil) 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
        [alert release];
    }
}

- (BOOL)isReachableInternet {
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    return netStatus != NotReachable;
}

@end
