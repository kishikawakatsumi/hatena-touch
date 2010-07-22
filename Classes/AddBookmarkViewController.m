    //
//  AddBookmarkViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "AddBookmarkViewController.h"
#import "MyBookmarkAPI.h"
#import "NetworkActivityManager.h"
#import "UserSettings.h"

@implementation AddBookmarkViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    bookmarkAPI.delegate = nil;
    [bookmarkAPI release];
    
    self.pageTitle = nil;
    self.pageURL = nil;
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    [contentView release];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 300.0f, 44.0f)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    titleLabel.numberOfLines = 2;
    [contentView addSubview:titleLabel];
    [titleLabel release];
    
    URLLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 52.0f, 300.0f, 40.0f)];
    URLLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    URLLabel.backgroundColor = [UIColor clearColor];
    URLLabel.font = [UIFont systemFontOfSize:12.0f];
    URLLabel.textColor = [UIColor darkGrayColor];
    URLLabel.numberOfLines = 2;
    URLLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    [contentView addSubview:URLLabel];
    [URLLabel release];
    
    commentField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 102.0f, 300.0f, 31.0f)];
    commentField.borderStyle = UITextBorderStyleBezel;
    [contentView addSubview:commentField];
    [commentField release];
    
    UIButton *addButton = [UIButton buttonWithType:111];
    addButton.frame =  CGRectMake(200.0f, 153.0f, 114.0f, 40.0f);
    [addButton setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addBookmark:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:addButton];
    
    blockView = [[UIView alloc] initWithFrame:contentView.frame];
    blockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blockView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    blockView.alpha = 0.0f;
    [contentView addSubview:blockView];
    [blockView release];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    indicatorView.hidesWhenStopped = YES;
    indicatorView.frame = CGRectMake((blockView.frame.size.width - indicatorView.frame.size.width) / 2, (blockView.frame.size.height - indicatorView.frame.size.height) / 2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    [blockView addSubview:indicatorView];
    [indicatorView release];
    
    [indicatorView startAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    titleLabel.text = self.pageTitle;
    URLLabel.text = self.pageURL;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)];
    [self.navigationItem setRightBarButtonItem:closeButton animated:NO];
    [closeButton release];
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

- (void)addBookmark:(id)sender {
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 1.0f;
    [UIView commitAnimations];
    
    bookmarkAPI = [[MyBookmarkAPI alloc] init];
    bookmarkAPI.delegate = self;
    [bookmarkAPI addBookmark:self.pageURL withComment:commentField.text];
}

- (void)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

- (void)myBookmarkAPI:(MyBookmarkAPI *)API didFinished:(id)responseData {
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 0.0f;
    [UIView commitAnimations];
    
    bookmarkAPI.delegate = nil;
    [bookmarkAPI release];
    bookmarkAPI = nil;
    
    [self dismiss:nil];
}

- (void)myBookmarkAPI:(MyBookmarkAPI *)API didFailed:(NSError *)error {
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 0.0f;
    [UIView commitAnimations];
    
    bookmarkAPI.delegate = nil;
    [bookmarkAPI release];
    bookmarkAPI = nil;
    
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                       message:[NSString stringWithFormat:@"%@", [error localizedDescription]] 
                                      delegate:self 
                             cancelButtonTitle:nil 
                             otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
    [alert release];
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    alert = nil;
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    [alert dismissWithClickedButtonIndex:0 animated:NO];
    alert = nil;
}

@end
