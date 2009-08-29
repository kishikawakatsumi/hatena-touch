#import "HatenaAtomPub.h"
#import "HatenaTouchAppDelegate.h"
#import "XMLParser.h"
#import "NSDataAdditions.h"
#import "CocoaCryptoHashing.h"
#import "NSString+XMLExtensions.h"
#import "Debug.h"

@implementation HatenaAtomPub

- (id)init {
	if (self = [super init]) {
		now = [[NSDate date] retain];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
		formattedDate = [[dateFormatter stringFromDate:now] retain];
	}
	return self;
}

- (void)dealloc {
	[formattedDate release];
	[dateFormatter release];
	[now release];
	[super dealloc];
}

#pragma mark Utility Methods

+ (UIView *)waitingView {
	CGRect viewFrame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	UIView *waitingView = [[UIView alloc] initWithFrame:viewFrame];
	waitingView.backgroundColor = [UIColor blackColor];
	waitingView.opaque = NO;
	waitingView.alpha = 0.5;
	waitingView.userInteractionEnabled = YES;
	
	CGRect indicatorFrame = CGRectMake(141.0, 180.0, 37.0, 37.0);
	UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:indicatorFrame];
	indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[indicatorView startAnimating];
	[waitingView addSubview:indicatorView];
	
	[indicatorView release];
	
	return [waitingView autorelease];	
}

- (void)showAlert:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) message:message
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (NSString *)makeCredentialsWithUserName:(NSString *)userName password:(NSString *)password {
	srand(time(nil));
	NSString *nonce = [[NSString stringWithFormat:@"%@%d", formattedDate, rand()] sha1HexHash];
	NSString *passwordDigest = [[[NSString stringWithFormat:@"%@%@%@", nonce, formattedDate, password] sha1Hash] base64Encoding];
	NSString *base64 = [[nonce dataUsingEncoding:NSASCIIStringEncoding] base64Encoding];
	NSString *credentials = [NSString stringWithFormat:
							 @"UsernameToken Username=\"%@\", "
							 @"PasswordDigest=\"%@\", "
							 @"Nonce=\"%@\", "
							 @"Created=\"%@\"", userName, passwordDigest, base64, formattedDate];
	return credentials;
}

- (NSString *)makeBlogBodyXML:(Diary *)entry {
	NSString *title = [NSString encodeXMLCharactersIn:entry.titleText];
	NSString *text = [NSString encodeXMLCharactersIn:entry.diaryText];
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

- (NSString *)makeImageBodyXMLWithTitle:(NSString *)title base64Image:(NSString *)base64Image {
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

- (NSString *)makeBookmarkBodyXMLWithURL:(NSString *)URL comment:(NSString *)comment {
	NSString *bodyXML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
						 @"<entry xmlns=\"http://purl.org/atom/ns#\">"
						 @"<link rel=\"related\" type=\"text/html\" href=\"%@\" />"
						 @"<summary type=\"text/plain\">%@</summary>"
						 @"</entry>", URL, comment];
	return bodyXML;
}

- (NSMutableURLRequest *)makeRequestWithURI:(NSString *)URI method:(NSString *) method {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	
	NSString *userName = userSettings.userName;
	NSString *password = userSettings.password;
	
	NSURL *webServiceURL = [NSURL URLWithString:URI];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:webServiceURL cachePolicy:NSURLRequestReturnCacheDataElseLoad 
												   timeoutInterval:30];
	
	NSString *credentials = [self makeCredentialsWithUserName:userName password:password];
	
	[req setHTTPMethod:method];
	[req addValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
	[req addValue:credentials forHTTPHeaderField:@"X-WSSE"];
	
	return req;
}

#pragma mark <AtomPub> Methods
#pragma mark Hatena Diary Methods

- (NSData *)requestBlogCollectionWhetherDraft:(BOOL)draft pageNumber:(NSInteger)page {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	NSString *userName = userSettings.userName;
	
	NSString *requestURI = [NSString stringWithFormat:@"http://d.hatena.ne.jp/%@/atom/%@/?page=%d",
							userName, draft ? @"draft" : @"blog", page];
	NSMutableURLRequest *req = [self makeRequestWithURI:requestURI method:@"GET"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURLResponse *res;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [(NSHTTPURLResponse *)res statusCode];
	if (statusCode == 200) {
		return data;
	}
	[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
					 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
	return nil;
}

- (NSData *)requestBlogEntryWithURI:(NSString *)editURI {
	NSMutableURLRequest *req = [self makeRequestWithURI:editURI method:@"GET"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURLResponse *res;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [(NSHTTPURLResponse *)res statusCode];
	if (statusCode == 200) {
		return data;
	}
	[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
					 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
	return nil;
}

- (NSString *)requestPostNewEntry:(Diary *)entry isDraft:(BOOL)draft {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	NSString *userName = userSettings.userName;
	
	NSString *URI = @"http://d.hatena.ne.jp/%@/atom/%@";
	NSString *requestURI = [NSString stringWithFormat:URI, userName, draft ? @"draft" : @"blog"];
	
	NSMutableURLRequest *req = [self makeRequestWithURI:requestURI method:@"POST"];
	
	NSString *bodyXML = [self makeBlogBodyXML:entry];
	[req setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSHTTPURLResponse *res;
	[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 201) {
		[self showAlert:[NSString stringWithFormat:@"%@\nstatus code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return nil;
	}
	
	return [[res allHeaderFields] objectForKey:@"Location"];
}

- (NSString *)requestPostNewEntry:(Diary *)entry {
	return [self requestPostNewEntry:entry isDraft:NO];
}

- (NSString *)requestPostNewDraft:(Diary *)entry {
	return [self requestPostNewEntry:entry isDraft:YES];
}

- (NSString *)requestPostNewEntryFromDraft:(Diary *)entry editURI:(NSString *)editURI {
	//まず元の下書きを修正する。成功なら、その下書きを公開する。
	if (![self requestEditEntry:entry editURI:editURI]) {
		return nil;
	}
	
	NSMutableURLRequest *req = [self makeRequestWithURI:editURI method:@"PUT"];
	NSString *bodyXML = [self makeBlogBodyXML:entry];
	
	[req addValue:@"1" forHTTPHeaderField:@"X-HATENA-PUBLISH"];
	[req setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSHTTPURLResponse *res;
	[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 200) {
		[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return nil;
	}
	
	return [[res allHeaderFields] objectForKey:@"Location"];
}

- (BOOL)requestEditEntry:(Diary *)entry editURI:(NSString *)editURI {
	NSMutableURLRequest *req = [self makeRequestWithURI:editURI method:@"PUT"];
	
	NSString *bodyXML = [self makeBlogBodyXML:entry];
	[req setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSHTTPURLResponse *res;
	[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 200) {
		[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return NO;
	}
	
	return YES;
}

- (BOOL)requestDeleteEntry:(NSString *)editURI {
	NSMutableURLRequest *req = [self makeRequestWithURI:editURI method:@"DELETE"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSHTTPURLResponse *res;
	[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 200) {
		[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return NO;
	}
	
	return YES;
}

- (NSDictionary *)requestPostNewImage:(UIImage *)image title:(NSString *)title {
	NSString *requestURI = @"http://f.hatena.ne.jp/atom/post";
	
	NSMutableURLRequest *req = [self makeRequestWithURI:requestURI method:@"POST"];
	
	NSString *bodyXML = [self makeImageBodyXMLWithTitle:title base64Image:[UIImagePNGRepresentation(image) base64Encoding]];
	[req setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSHTTPURLResponse *res;
	NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	XMLParser *parser = [[XMLParser alloc] autorelease];
	[parser parseXMLOfData:data entryTag:@"entry" parseError:nil];
	NSArray *items = [parser items];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 201) {
		[self showAlert:[NSString stringWithFormat:@"%@\nstatus code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return nil;
	}
	
	return [items objectAtIndex:0];
}

#pragma mark MyBookmark Methods

- (BOOL)requestAddNewBookmark:(NSString *)urlString:(NSString *)comment {
	NSMutableURLRequest *req = [self makeRequestWithURI:@"http://b.hatena.ne.jp/atom/post" method:@"POST"];
	
	NSString *bodyXML = [self makeBookmarkBodyXMLWithURL:urlString comment:comment];

	[req setHTTPBody:[bodyXML dataUsingEncoding:NSUTF8StringEncoding]];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	NSHTTPURLResponse *res;
	[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 201) {
		[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return NO;
	}
	
	return YES;
}

- (NSData *)requestMyBookmarkFeed {
	return [self requestMyBookmarkFeed:0];
}

- (NSData *)requestMyBookmarkFeed:(NSInteger)offset {
	NSMutableURLRequest *req = [self makeRequestWithURI:[NSString stringWithFormat:@"http://b.hatena.ne.jp/atom/feed?of=%d", offset]
												 method:@"GET"];
  
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSData *data;
	NSHTTPURLResponse *res;
	NSError *error;
	data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 200) {
		[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return nil;
	}
	
	return data;
}

- (BOOL)requestDeleteMyBookmark:(NSString *)editURI {
	NSMutableURLRequest *req = [self makeRequestWithURI:editURI method:@"DELETE"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSHTTPURLResponse *res;
	NSError *error;
	[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSInteger statusCode = [res statusCode];
	if (statusCode != 200) {
		[self showAlert:[NSString stringWithFormat:@"%@\nStatus Code = %d",
						 [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode]];
		return NO;
	}
	
	return YES;
}

@end
