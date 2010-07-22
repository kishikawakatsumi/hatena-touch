//
//  DiaryUploader.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Diary.h"

@interface DiaryUploader : NSObject {
    NSInteger statusCode;
    NSInteger expectedStatusCode;
    DiaryUploader *diaryUploader;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) id publishDiary;
@property (nonatomic, retain) id publishEditURI;

- (void)uploadDiary:(Diary *)diary;
- (void)publishDraft:(Diary *)diary editURI:(NSString *)editURI;
- (void)saveDraft:(Diary *)diary;
- (void)updateDiary:(Diary *)diary editURI:(NSString *)editURI;
- (void)deleteDiaryWithEditURI:(NSString *)editURI;

@end

@protocol DiaryUploaderDelegate<NSObject>

- (void)diaryUploader:(DiaryUploader *)uploader uploadFinished:(id)responseData;
- (void)diaryUploader:(DiaryUploader *)uploader uploadFailed:(NSError *)error;

@end
