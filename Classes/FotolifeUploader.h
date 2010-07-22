//
//  FotolifeUploader.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HatenaAtomPubResponseParser;

@interface FotolifeUploader : NSObject {
    NSInteger statusCode;
    HatenaAtomPubResponseParser *responseParser;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, retain) NSMutableData *receivedData;

- (void)uploadImage:(UIImage *)image title:(NSString *)title;

@end

@protocol FotolifeUploaderDelegate<NSObject>

- (void)imageUploader:(FotolifeUploader *)uploader uploadFinished:(id)responseData;
- (void)imageUploader:(FotolifeUploader *)uploader uploadFailed:(NSError *)error;

@end
