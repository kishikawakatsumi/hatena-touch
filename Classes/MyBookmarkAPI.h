//
//  MyBookmarkAPI.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyBookmarkAPI : NSObject {
    NSInteger statusCode;
    NSInteger expectedStatusCode;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) id publishEditURI;

- (void)addBookmark:(NSString *)URL withComment:(NSString *)comment;
- (void)deleteBookmark:(NSString *)editURI;

@end

@protocol MyBookmarkAPIDelegate<NSObject>

- (void)myBookmarkAPI:(MyBookmarkAPI *)API didFinished:(id)responseData;
- (void)myBookmarkAPI:(MyBookmarkAPI *)API didFailed:(NSError *)error;

@end

