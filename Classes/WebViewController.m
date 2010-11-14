    //
//  WebViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/13.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "WebViewController.h"
#import "AddBookmarkViewController.h"
#import "CommentViewController.h"
#import "MyBookmarkAPI.h"
#import "UserSettings.h"
#import "JSON.h"
#import "NetworkActivityManager.h"

@interface WebViewController(Private)
- (NSString *)encodeString:(NSString *)string;
@end

@implementation WebViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    self.pageURL = nil;
    self.comments = nil;
    self.connection = nil;
    self.receivedData = nil;
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    [contentView release];
    
    web = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 372.0f)];
    web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    web.delegate = self;
    web.scalesPageToFit = YES;
    [contentView addSubview:web];
    [web release];
    
    commentButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comments_small.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showComments:)];
    commentButton.enabled = NO;
    [self.navigationItem setRightBarButtonItem:commentButton animated:NO];
    [commentButton release];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 372.0f, 320.0f, 44.0f)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    [contentView addSubview:toolbar];
    [toolbar release];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBack.png"] style:UIBarButtonItemStylePlain target:web action:@selector(goBack)];
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavForward.png"] style:UIBarButtonItemStylePlain target:web action:@selector(goForward)];
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:web action:@selector(reload)];
    UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:web action:@selector(stopLoading)];
    bookmarkButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark_small.png"] style:UIBarButtonItemStylePlain target:self action:@selector(bookmark:)];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, reloadButton, flexibleSpace, stopButton, flexibleSpace, bookmarkButton, flexibleSpace, actionButton, flexibleSpace, nil] animated:NO];
    
    [flexibleSpace release];
    [backButton release];
    [forwardButton release];
    [reloadButton release];
    [bookmarkButton release];
    [actionButton release];
    [stopButton release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (&UIApplicationDidEnterBackgroundNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 45.0f, 200.0f, 36.0f)];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textAlignment = UITextAlignmentCenter;
    titleView.textColor = [UIColor whiteColor];
    titleView.shadowColor = [UIColor darkGrayColor];
    titleView.shadowOffset = CGSizeMake(0.0f, -1.0f);
    titleView.font = [UIFont boldSystemFontOfSize:14.0f];
    titleView.numberOfLines = 2;
    self.navigationItem.titleView = titleView;
    [titleView release];
    
    UserSettings *settings = [UserSettings sharedInstance];
    
    bookmarkButton.enabled = [settings.userName length] > 0 && [settings.password length] > 0;
    
    useMobilizer = settings.useMobileProxy;
    if (useMobilizer) {
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://instapaper.com/m?u=%@", [self encodeString:self.pageURL]]] 
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                           timeoutInterval:30.0]];
    } else {
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.pageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0]];
    }
    
    self.connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://b.hatena.ne.jp/entry/jsonlite/?url=%@", self.pageURL]] 
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                                          timeoutInterval:30.0] delegate:self];
    [self.connection start];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    UserSettings *settings = [UserSettings sharedInstance];
    return settings.shouldAutoRotation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (NSString *)encodeString:(NSString *)string {
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                           (CFStringRef)string, 
                                                                           NULL, 
                                                                           (CFStringRef)@";/?:@&=$+{}<>,",
                                                                           kCFStringEncodingUTF8);
    return [result autorelease];
}

#pragma mark -

- (void)showComments:(id)sender {
    CommentViewController *controller = [[CommentViewController alloc] init];
    controller.data = self.comments;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [controller release];
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

- (void)bookmark:(id)sender {
    AddBookmarkViewController *controller = [[AddBookmarkViewController alloc] init];
    controller.pageTitle = titleView.text;
    controller.pageURL = self.pageURL;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [controller release];
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

- (void)action:(id)sender {
    sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                          destructiveButtonTitle:nil 
                               otherButtonTitles:useMobilizer ? NSLocalizedString(@"OriginalPage", nil) : NSLocalizedString(@"UseMobilizer", nil), NSLocalizedString(@"OpenSafari", nil), nil];
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark -

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    titleView.text = self.pageURL;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    titleView.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title;"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    if ([error code] != -999) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                           message:[NSString stringWithFormat:@"%@", [error localizedDescription]] 
                                          delegate:self 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
        [alert release];
    }
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *JSON = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    self.comments = [JSON JSONValue];
    if (self.comments) {
        commentButton.enabled = YES;
    }
    [JSON release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.receivedData = nil;
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    alert = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [web stopLoading];
        
        useMobilizer = !useMobilizer;
        if (useMobilizer) {
            [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://instapaper.com/m?u=%@", [self encodeString:self.pageURL]]] 
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                          timeoutInterval:30.0]];
        } else {
            [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.pageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0]];
        }
    } else if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.pageURL]];
    }    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    [alert dismissWithClickedButtonIndex:0 animated:NO];
    alert = nil;
    
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:2 animated:NO];
        sheet = nil;
    }
    
    if (self.modalViewController) {
        [self.modalViewController dismissModalViewControllerAnimated:NO];
    }
}

@end
