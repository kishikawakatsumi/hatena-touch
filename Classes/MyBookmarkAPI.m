//
//  MyBookmarkAPI.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "MyBookmarkAPI.h"
#import "HatenaAtomPub.h"
#import "UserSettings.h"

@implementation MyBookmarkAPI

@synthesize delegate;
@synthesize statusCode;
@synthesize location;
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
    self.publishEditURI = nil;
    [super dealloc];
}

- (NSString *)makeBodyXML:(NSString *)URL withComment:(NSString *)comment {
	NSString *bodyXML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
						 @"<entry xmlns=\"http://purl.org/atom/ns#\">"
						 @"<link rel=\"related\" type=\"text/html\" href=\"%@\" />"
						 @"<summary type=\"text/plain\">%@</summary>"
						 @"</entry>", URL, comment];
	return bodyXML;
}

- (void)addBookmark:(NSString *)URL withComment:(NSString *)comment {
    expectedStatusCode = 201;
    
    if (comment == nil) {
        comment = @"";
    }
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
    NSMutableURLRequest *request = [atomPub makeRequestWithURI:@"http://b.hatena.ne.jp/atom/post" method:@"POST"];
    
	NSString *bodyXML = [self makeBodyXML:URL withComment:comment];
	[request setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    [atomPub release];
}

- (void)updateBookmark:(NSString *)URL {
}

- (void)deleteBookmark:(NSString *)editURI {
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
    if ([self.delegate respondsToSelector:@selector(myBookmarkAPI:didFailed:)]) {
        [self.delegate myBookmarkAPI:self didFailed:error];
    }
    
    [self autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (statusCode == expectedStatusCode) {
        if ([self.delegate respondsToSelector:@selector(myBookmarkAPI:didFinished:)]) {
            [self.delegate myBookmarkAPI:self didFinished:self.location];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(myBookmarkAPI:didFailed:)]) {
            [self.delegate myBookmarkAPI:self didFailed:nil];
        }
    }
    
    [self autorelease];
}

@end
