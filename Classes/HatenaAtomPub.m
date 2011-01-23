//
//  HatenaAtomPub.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "HatenaAtomPub.h"
#import "UserSettings.h"
#import "CocoaCryptoHashing.h"
#import "NSData+Base64.h"

@implementation HatenaAtomPub

- (id)init {
    if (self = [super init]) {
        now = [[NSDate date] retain];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        formattedDate = [[dateFormatter stringFromDate:now] retain];
    }
    return self;
}

- (void)dealloc {
    [now release];
    [dateFormatter release];
    [formattedDate release];
    [super dealloc];
}

#pragma mark -

- (NSString *)makeCredentialsWithUsername:(NSString *)username password:(NSString *)password {
	NSString *nonce = [[NSString stringWithFormat:@"%@%d", formattedDate, arc4random()] sha1HexHash];
	NSString *passwordDigest = [[[NSString stringWithFormat:@"%@%@%@", nonce, formattedDate, password] sha1Hash] base64EncodedString];
	NSString *base64 = [[nonce dataUsingEncoding:NSASCIIStringEncoding] base64EncodedString];
	NSString *credentials = [NSString stringWithFormat:
							 @"UsernameToken Username=\"%@\", "
							 @"PasswordDigest=\"%@\", "
							 @"Nonce=\"%@\", "
							 @"Created=\"%@\"", username, passwordDigest, base64, formattedDate];
	return credentials;
}

- (NSMutableURLRequest *)makeRequestWithURI:(NSString *)URI method:(NSString *)method {
	UserSettings *settings = [UserSettings sharedInstance];
	NSString *username = settings.userName;
	NSString *password = settings.password;
	
	NSURL *webServiceURL = [NSURL URLWithString:URI];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:webServiceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	NSString *credentials = [self makeCredentialsWithUsername:username password:password];
	
	[req setHTTPMethod:method];
	[req addValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
	[req addValue:credentials forHTTPHeaderField:@"X-WSSE"];
	
	return req;
}

@end
