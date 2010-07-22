//
//  NetworkActivityManager.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "NetworkActivityManager.h"

static NetworkActivityManager *sharedInstance;

@implementation NetworkActivityManager

+ (NetworkActivityManager *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[NetworkActivityManager alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        networkStack = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [networkStack release];
    [super dealloc];
}

- (void)pushActivity:(id)identifier {
    if ([networkStack count] == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    NSObject *obj = [[NSObject alloc] init];
    NSMutableArray *stack = [networkStack objectForKey:identifier];
    if (!stack) {
        stack = [NSMutableArray array];
        [networkStack setObject:stack forKey:identifier];
    }
    [stack addObject:obj];
    [obj release];
}

- (void)popActivity:(id)identifier {
    NSMutableArray *stack = [networkStack objectForKey:identifier];
    if (stack) {
        [stack removeLastObject];
        if ([stack count] == 0) {
            [networkStack removeObjectForKey:identifier];
        }
    }
    if ([networkStack count] == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
