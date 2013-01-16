//
//  FotolifeUploader.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "FotolifeUploader.h"
#import "HatenaAtomPubResponseParser.h"
#import "HatenaAtomPub.h"
#import "UserSettings.h"
#import "NSData+Base64.h"
#import "UIImage+Utilities.h"

@implementation FotolifeUploader

@synthesize delegate;
@synthesize statusCode;
@synthesize receivedData;

- (id)init {
    self = [super init];
    if (self) {
        self.receivedData = [NSMutableData data];
        [self retain];
    }
    
    return self;
}

- (void)dealloc {
    self.receivedData = nil;
    [super dealloc];
}

- (NSString *)makeImageUploadXMLWithTitle:(NSString *)title base64Image:(NSString *)base64Image {
	NSString *bodyXML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
						 @"<entry xmlns=\"http://purl.org/atom/ns#\">"
						 @"<title>%@</title>"
						 @"<content mode=\"base64\" type=\"image/jpeg\">"
						 @"%@"
						 @"</content>"
						 @"</entry>",
						 title, base64Image];
	return bodyXML;
}

- (void)uploadImage:(UIImage *)image title:(NSString *)title {
    UIImage *uploadImage = nil;
    
    UserSettings *settings = [UserSettings sharedInstance];
    CGSize imageSize = image.size;
	switch (settings.imageSize) {
		case UserSettingsImageSizeSmall:
			imageSize = CGSizeMake(320.0f, 480.0f);
			break;
		case UserSettingsImageSizeMedium:
			imageSize = CGSizeMake(480.0f, 720.0f);
			break;
		case UserSettingsImageSizeLarge:
			imageSize = CGSizeMake(640.0f, 960.0f);
			break;
		case UserSettingsImageSizeExtraLarge:
			imageSize = CGSizeMake(800.0f, 1200.0f);
			break;
		default:
			break;
	}

    uploadImage = [image resizedImage:imageSize imageOrientation:image.imageOrientation];
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	NSMutableURLRequest *request = [atomPub makeRequestWithURI:@"http://f.hatena.ne.jp/atom/post" method:@"POST"];
	
	NSString *bodyXML = [self makeImageUploadXMLWithTitle:title base64Image:[UIImageJPEGRepresentation(uploadImage, 0.5f) base64EncodedString]];
	[request setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.receivedData = [[[NSMutableData alloc] init] autorelease];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    [atomPub release];
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {    
    statusCode = [(NSHTTPURLResponse *)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(imageUploader:uploadFailed:)]) {
        [self.delegate imageUploader:self uploadFailed:error];
    }
    
    [self autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (statusCode == 201) {
        responseParser = [[HatenaAtomPubResponseParser alloc] init];
        responseParser.delegate = self;
        [responseParser parseWithData:self.receivedData];
    }
}

#pragma mark -

- (void)parserFinished:(HatenaAtomPubResponseParser *)parser {
    if ([self.delegate respondsToSelector:@selector(imageUploader:uploadFinished:)]) {
        [self.delegate imageUploader:self uploadFinished:parser.entry];
    }
    [parser release];
    
    [self autorelease];
}

- (void)parser:(HatenaAtomPubResponseParser *)parser encounteredError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(imageUploader:uploadFailed:)]) {
        [self.delegate imageUploader:self uploadFailed:error];
    }
    [parser release];
    
    [self autorelease];
}

@end
