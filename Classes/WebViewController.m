#import "WebViewController.h"
#import "HatenaTouchAppDelegate.h"
#import "InformationSheetController.h"
#import "JSON/JSON.h"
#import "Debug.h"
#import <objc/runtime.h>

@implementation WebViewController

@synthesize webView;
@synthesize backButton;
@synthesize forwardButton;
@synthesize pageURL;
@synthesize lastPageURL;

static NSObject *webViewcreateWebViewWithRequestIMP(id self, SEL _cmd, NSObject* sender, NSObject* request) {
	return [sender retain];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		UIBarButtonItem *commentButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Comment.png"]
																	   style:UIBarButtonItemStyleBordered target:self action:@selector(showInfoMenu)];
		[[self navigationItem] setRightBarButtonItem:commentButton];
		[commentButton release];
	}
	return self;
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[lastPageURL release];
	[pageURL release];
	[forwardButton release];
	[backButton release];
	[webView setDelegate:nil];
	[webView release];
	[super dealloc];
}

- (void)_loadPageInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSURL *webServiceURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://b.hatena.ne.jp/entry/jsonlite/%@", pageURL]];
	NSURLRequest *req = [NSURLRequest requestWithURL:webServiceURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
	
	NSData *data;
	NSHTTPURLResponse *res;
	NSError *error;
	data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];

	NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	pageInfo = [[json JSONValue] retain];
	
	[[[self navigationItem] rightBarButtonItem] setEnabled:YES];
	
	[pool release];
}

- (void)_loadPageInfo:(id)timer {
	NSURL *aURL = [webView.request mainDocumentURL];
	if (!aURL) {
		return;
	}
	[NSThread detachNewThreadSelector:@selector(_loadPageInfo) toTarget:self withObject:nil];
	[timer invalidate];
}

- (void)showInfoMenu {
	isInfoMenuPresent = YES;
	InformationSheetController *controller = [[InformationSheetController alloc] initWithNibName:@"InformationSheet" bundle:nil];
	
	controller.pageInfo = pageInfo;
	controller.bookmarks = [pageInfo objectForKey:@"bookmarks"];
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)startLoading {
	if ([pageURL isEqualToString:lastPageURL] && loadFinishedSuccesefully) {
		return;
	}
	
	self.lastPageURL = pageURL;

	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	NSURL *url;
	if (userSettings.useMobileProxy) {
		url = [NSURL URLWithString:[[NSString stringWithFormat:@"http://www.google.co.jp/gwt/n?u=%@", pageURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	} else {
		url = [NSURL URLWithString:pageURL];
	}

	[webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)actionButtonPushed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:NSLocalizedString(@"ReloadThisPage", nil)
								  delegate:self
								  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
								  destructiveButtonTitle:nil
								  otherButtonTitles:
								  NSLocalizedString(@"DirectAccess", nil),
								  NSLocalizedString(@"WithMobileProxy", nil),
								  NSLocalizedString(@"OpenSafari", nil), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

#pragma mark <UIActionSheetDelegate> Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	LOG(@"action button pushed: %d", buttonIndex);
	if (buttonIndex == 0) {
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pageURL]]];
	} else if (buttonIndex == 1) {
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.google.co.jp/gwt/n?u=%@", pageURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
	} else if (buttonIndex == 2) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:pageURL]];
	}
}

#pragma mark <UIWebViewDelegate> Methods

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *aURL = [[request URL] absoluteString];
	NSString *mainDocumentURL = [request.mainDocumentURL absoluteString];
	if (mainDocumentURL == nil || ![mainDocumentURL isEqualToString:aURL]) {
		return NO;
	}
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked ||
		navigationType == UIWebViewNavigationTypeFormSubmitted ||
		navigationType == UIWebViewNavigationTypeBackForward ||
		navigationType == UIWebViewNavigationTypeFormResubmitted) {
		self.lastPageURL = mainDocumentURL;
	}
	
	LOG(@"<%@>", [request URL]);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	backButton.enabled = (webView.canGoBack) ? YES : NO;
    forwardButton.enabled = (webView.canGoForward) ? YES : NO;
	
	LOG_CURRENT_METHOD;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	loadFinishedSuccesefully = YES;
	
	backButton.enabled = (webView.canGoBack) ? YES : NO;
    forwardButton.enabled = (webView.canGoForward) ? YES : NO;
	
	self.title = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
	
	LOG_CURRENT_METHOD;
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	loadFinishedSuccesefully = NO;
	
	backButton.enabled = (webView.canGoBack) ? YES : NO;
    forwardButton.enabled = (webView.canGoForward) ? YES : NO;
	
	LOG_CURRENT_METHOD;
}

#pragma mark <UIViewController> Methods

- (void)viewDidLoad {
    [super viewDidLoad];
	[webView setBackgroundColor:[UIColor whiteColor]];
	Class UIWebViewWebViewDelegate = objc_getClass("UIWebViewWebViewDelegate");
	class_addMethod(UIWebViewWebViewDelegate, @selector(webView:createWebViewWithRequest:), 
					(IMP)webViewcreateWebViewWithRequestIMP, "@@:@@");
}

- (void)viewWillAppear:(BOOL)animated {
	if (isInfoMenuPresent) {
		isInfoMenuPresent = NO;
		return;
	}
    [super viewWillAppear:animated];
	
	backButton.enabled = (webView.canGoBack) ? true : false;
    forwardButton.enabled = (webView.canGoForward) ? true : false;
	
	[self startLoading];
	[[[self navigationItem] rightBarButtonItem] setEnabled:NO];
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_loadPageInfo:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (isInfoMenuPresent) {
		return;
	}
	[super viewWillDisappear:animated];
	[webView stopLoading];
	[pageInfo release];
	pageInfo = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (fromInterfaceOrientation == UIDeviceOrientationIsPortrait(fromInterfaceOrientation)) {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	} else {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	return userSettings.shouldAutoRotation;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
