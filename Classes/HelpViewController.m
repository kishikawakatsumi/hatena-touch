    //
//  HelpViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/22.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "HelpViewController.h"
#import "UserSettings.h"

@implementation HelpViewController

- (void)dealloc {
    [super dealloc];
}

- (void)loadView {    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    [contentView release];
    
    web = [[UIWebView alloc] initWithFrame:contentView.frame];
    web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    web.scalesPageToFit = YES;
    [contentView addSubview:web];
    [web release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Help", nil);
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help.html" ofType:nil]]]];
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
}

@end
