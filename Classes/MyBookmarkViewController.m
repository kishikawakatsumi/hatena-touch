    //
//  MyBookmarkViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "MyBookmarkViewController.h"
#import "WebViewController.h"
#import "EntryCell.h"
#import "HatenaAtomPub.h"
#import "MyBookmarkAPI.h"
#import "MyBookmarkFeedParser.h"
#import "UserSettings.h"
#import "NetworkActivityManager.h"
#import "InternetReachability.h"

@interface MyBookmarkViewController(Private)
- (void)loadNextData;
@end

@implementation MyBookmarkViewController

- (id)init {
    if (self = [super init]) {
        data = [[NSMutableArray alloc] initWithCapacity:30];
        hasMoreData = YES;
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    [data release];
    self.parser.delegate = nil;
    self.parser = nil;
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    [contentView release];
    
    listView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    listView.delegate = self;
    listView.dataSource = self;
    listView.rowHeight = 80.0f;
    [contentView addSubview:listView];
    [listView release];
    
    UIView *autoPagarizeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    autoPagarizeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    listView.tableFooterView = autoPagarizeView;
    [autoPagarizeView release];
    
    dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot.png"]];
    dotImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    dotImageView.hidden = YES;
    dotImageView.frame = CGRectMake((autoPagarizeView.frame.size.width - dotImageView.frame.size.width) / 2, (autoPagarizeView.frame.size.height - dotImageView.frame.size.height) / 2, dotImageView.frame.size.width, dotImageView.frame.size.height);
    [autoPagarizeView addSubview:dotImageView];
    [dotImageView release];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.frame = CGRectMake((autoPagarizeView.frame.size.width - activityIndicator.frame.size.width) / 2, (autoPagarizeView.frame.size.height - activityIndicator.frame.size.height) / 2, activityIndicator.frame.size.width, activityIndicator.frame.size.height);
    [autoPagarizeView addSubview:activityIndicator];
    [activityIndicator release];
    
    blockView = [[UIView alloc] initWithFrame:contentView.frame];
    blockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blockView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    blockView.alpha = 0.0f;
    [contentView addSubview:blockView];
    [blockView release];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    indicator.hidesWhenStopped = YES;
    indicator.frame = CGRectMake((blockView.frame.size.width - indicator.frame.size.width) / 2, (blockView.frame.size.height - indicator.frame.size.height + 20.0f) / 2, indicator.frame.size.width, indicator.frame.size.height);
    [blockView addSubview:indicator];
    [indicator release];
    
    [indicator startAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.title = NSLocalizedString(@"MyBookmark", nil);
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
                                          [UIImage imageNamed:@"arrow_left_small.png"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:nil 
                                                                         action:nil];
    [self.navigationItem setBackBarButtonItem:backBarButtonItem];
    [backBarButtonItem release];
    
    [activityIndicator startAnimating];
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    [self loadNextData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [listView flashScrollIndicators];
    [listView deselectRowAtIndexPath:[listView indexPathForSelectedRow] animated:YES];
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
    listView = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [listView setEditing:editing animated:animated];
}

#pragma mark -

- (void)loadNextData {
    if (![[InternetReachability sharedInstance] isReachableInternet]) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                           message:NSLocalizedString(@"No internet connection.", nil) 
                                          delegate:self 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
        [alert release];
        return;
    }
    
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    dotImageView.hidden = YES;
    [activityIndicator startAnimating];
    
    loading = YES;
    self.parser = [[[MyBookmarkFeedParser alloc] init] autorelease];
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
    self.parser.request = [atomPub makeRequestWithURI:[NSString stringWithFormat:@"http://b.hatena.ne.jp/atom/feed?of=%d", offset] method:@"GET"];
    self.parser.delegate = self;
    [self.parser parse];
    
    [atomPub release];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    EntryCell *cell = (EntryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSUInteger row = indexPath.row;
    
    NSDictionary *item = [data objectAtIndex:row];
    cell.title = [item objectForKey:@"title"];
    cell.description = [item objectForKey:@"link"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!hasMoreData || loading) {
        return;
    }
    
    NSUInteger row = indexPath.row;
    if (row == [data count] - 1) {
        offset += 20;
        [self loadNextData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    
    NSDictionary *entry = [data objectAtIndex:row];
    
    WebViewController *controller = [[WebViewController alloc] init];
    controller.pageURL = [entry objectForKey:@"link"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    UserSettings *settings = [UserSettings sharedInstance];
    return [NSString stringWithFormat:NSLocalizedString(@"BookmarkOf", nil), settings.userName];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.targetIndexPath = indexPath;
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:nil];
        [sheet showInView:self.view];
        [sheet release];
    }
}

#pragma mark -

- (void)myBookmarkAPI:(MyBookmarkAPI *)API didFinished:(id)responseData {
    [data removeObjectAtIndex:self.targetIndexPath.row];
    [listView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.targetIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    self.bookmarkAPI = nil;
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 0.0f;
    [UIView commitAnimations];
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
}

- (void)myBookmarkAPI:(MyBookmarkAPI *)API didFailed:(NSError *)error {
    self.bookmarkAPI = nil;
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 0.0f;
    [UIView commitAnimations];
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                           message:[NSString stringWithFormat:@"%@", [error localizedDescription]] 
                                          delegate:self 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
        [alert release];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                           message:[NSString stringWithFormat:@"%@\nStatus Code = %d", [NSHTTPURLResponse localizedStringForStatusCode:API.statusCode], API.statusCode] 
                                          delegate:self 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
        [alert release];
    }
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
        [UIView beginAnimations:nil context:nil];
        blockView.alpha = 1.0f;
        [UIView commitAnimations];
        
        NSUInteger row = self.targetIndexPath.row;
        NSDictionary *entry = [data objectAtIndex:row];
        
        self.bookmarkAPI = [[[MyBookmarkAPI alloc] init] autorelease];
        self.bookmarkAPI.delegate = self;
        [self.bookmarkAPI deleteBookmark:[entry objectForKey:@"edit"]];
    } else {
        [listView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.targetIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
}

#pragma mark -

- (void)parser:(MyBookmarkFeedParser *)parser addEntry:(id)entry {
    [data addObject:entry];
    [listView reloadData];
}

- (void)parser:(MyBookmarkFeedParser *)parser encounteredError:(NSError *)error {
    self.parser = nil;
    
    loading = NO;
    
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    dotImageView.hidden = NO;
    [activityIndicator stopAnimating];
    
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                       message:[error localizedDescription] 
                                      delegate:self 
                             cancelButtonTitle:nil 
                             otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
    [alert release];
}

- (void)parserFinished:(MyBookmarkFeedParser *)parser {
    if ([[parser.bookmarks objectForKey:@"entries"] count] < 20) {
        hasMoreData = NO;
        dotImageView.hidden = NO;
        [activityIndicator stopAnimating];
    }
    
    self.parser = nil;
    
    loading = NO;
    
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
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
