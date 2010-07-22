//
//  NetworkActivityManager.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityManager : NSObject {
    NSMutableDictionary *networkStack;
}

+ (NetworkActivityManager *)sharedInstance;
- (void)pushActivity:(id)identifier;
- (void)popActivity:(id)identifier;

@end
