//
//  HatenaAtomPub.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HatenaAtomPub : NSObject {
    NSDate *now;
    NSDateFormatter *dateFormatter;
    NSString *formattedDate;
}

- (NSMutableURLRequest *)makeRequestWithURI:(NSString *)URI method:(NSString *)method;

@end
