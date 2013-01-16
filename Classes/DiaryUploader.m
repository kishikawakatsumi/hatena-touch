//
//  DiaryUploader.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "DiaryUploader.h"
#import "HatenaAtomPub.h"
#import "UserSettings.h"
#import "NSData+Base64.h"
#import "NSString+XMLExtensions.h"

@implementation DiaryUploader

@synthesize delegate;
@synthesize statusCode;
@synthesize location;
@synthesize publishDiary;
@synthesize publishEditURI;

- (id)init {
    self = [super init];
	if (self) {
        [self retain];
	}
	return self;
}

- (void)dealloc {
    self.location = nil;
    self.publishDiary = nil;
    self.publishEditURI = nil;
    diaryUploader.delegate = nil;
    [diaryUploader release];
    [super dealloc];
}

- (NSString *)makeBodyXML:(Diary *)diary {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
    NSString *formattedDate = [dateFormatter stringFromDate:now];
    [dateFormatter release];
    
	NSString *title = [NSString encodeXMLCharactersIn:diary.titleText];
	NSString *text = [NSString encodeXMLCharactersIn:diary.diaryText];
	NSString *bodyXML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
						 @"<entry xmlns=\"http://purl.org/atom/ns#\">"
						 @"<title>%@</title>"
						 @"<content type=\"text/plain\">"
						 @"%@"
						 @"</content>"
						 @"<updated>%@</updated>"
						 @"</entry>",
						 title, text, formattedDate];
	return bodyXML;
}

- (void)uploadDiary:(Diary *)diary {
    expectedStatusCode = 201;
    
	UserSettings *settings = [UserSettings sharedInstance];
	NSString *username = settings.userName;
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
    NSMutableURLRequest *request = [atomPub makeRequestWithURI:[NSString stringWithFormat:@"http://d.hatena.ne.jp/%@/atom/blog", username] method:@"POST"];
    
	NSString *bodyXML = [self makeBodyXML:diary];
	[request setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    [atomPub release];
}

- (void)publishDraft:(Diary *)diary editURI:(NSString *)editURI {
	//まず元の下書きを修正する。成功なら、その下書きを公開する。
    self.publishDiary = diary;
    self.publishEditURI = editURI;
    
    
    diaryUploader = [[DiaryUploader alloc] init];
    diaryUploader.delegate = self;
    
	[diaryUploader updateDiary:diary editURI:editURI];
}

- (void)saveDraft:(Diary *)diary {
    expectedStatusCode = 201;
    
	UserSettings *settings = [UserSettings sharedInstance];
	NSString *username = settings.userName;
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
    NSMutableURLRequest *request = [atomPub makeRequestWithURI:[NSString stringWithFormat:@"http://d.hatena.ne.jp/%@/atom/draft", username] method:@"POST"];
    
	NSString *bodyXML = [self makeBodyXML:diary];
	[request setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    [atomPub release];
}

- (void)updateDiary:(Diary *)diary editURI:(NSString *)editURI {
    expectedStatusCode = 200;
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	NSMutableURLRequest *request = [atomPub makeRequestWithURI:editURI method:@"PUT"];
    
	NSString *bodyXML = [self makeBodyXML:diary];
	[request setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    [atomPub release];
}

- (void)deleteDiaryWithEditURI:(NSString *)editURI {
    expectedStatusCode = 200;
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	NSMutableURLRequest *request = [atomPub makeRequestWithURI:editURI method:@"DELETE"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    [atomPub release];
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {    
    statusCode = [(NSHTTPURLResponse *)response statusCode];
    self.location = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Location"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(diaryUploader:uploadFailed:)]) {
        [self.delegate diaryUploader:self uploadFailed:error];
    }
    
    [self autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (statusCode == expectedStatusCode) {
        if ([self.delegate respondsToSelector:@selector(diaryUploader:uploadFinished:)]) {
            [self.delegate diaryUploader:self uploadFinished:self.location];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(diaryUploader:uploadFailed:)]) {
            [self.delegate diaryUploader:self uploadFailed:nil];
        }
    }
    
    [self autorelease];
}

#pragma mark -

- (void)diaryUploader:(DiaryUploader *)uploader uploadFinished:(id)responseData {    
    expectedStatusCode = 200;
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	NSMutableURLRequest *request = [atomPub makeRequestWithURI:self.publishEditURI method:@"PUT"];
    
	NSString *bodyXML = [self makeBodyXML:self.publishDiary];
	[request setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
	[request addValue:@"1" forHTTPHeaderField:@"X-HATENA-PUBLISH"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    [atomPub release];
    
    self.publishDiary = nil;
    self.publishEditURI = nil;
    
    diaryUploader.delegate = nil;
    [diaryUploader release];
    diaryUploader = nil;
}

- (void)diaryUploader:(DiaryUploader *)uploader uploadFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(diaryUploader:uploadFailed:)]) {
        [self.delegate diaryUploader:self uploadFailed:error];
    }
    self.publishDiary = nil;
    self.publishEditURI = nil;
    
    diaryUploader.delegate = nil;
    [diaryUploader release];
    diaryUploader = nil;
    
    [self autorelease];
}

@end
