//
//  InternetReachability.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/22.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface InternetReachability : NSObject {
    Reachability* internetReach;
}

+ (InternetReachability *)sharedInstance;
- (BOOL)isReachableInternet;

@end
