    //
//  DiaryListViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "DiaryListViewController.h"
#import "DiaryViewController.h"
#import "DiaryCell.h"
#import "DiaryUploader.h"
#import "HatenaAtomPub.h"
#import "DiaryFeedParser.h"
#import "UserSettings.h"
#import "NetworkActivityManager.h"
#import "InternetReachability.h"

static NSDateFormatter *dateFormatter1;
static NSDateFormatter *dateFormatter2;

@interface DiaryListViewController(Private)
- (void)loadNextData;
@end

@implementation DiaryListViewController

+ (void)initialize {
	dateFormatter1 = [[NSDateFormatter alloc] init];
	[dateFormatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
	dateFormatter2 = [[NSDateFormatter alloc] init];
	[dateFormatter2 setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter2 setTimeStyle:NSDateFormatterMediumStyle];
}

- (id)init {
    if (self = [super init]) {
        data = [[NSMutableArray alloc] initWithCapacity:30];
        page = 1;
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
    self.uploader.delegate = nil;
    self.uploader = nil;
    self.targetIndexPath = nil;
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    [contentView release];
    
    listView = [[UITableView alloc] initWithFrame:contentView.frame];
    listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    listView.delegate = self;
    listView.dataSource = self;
    listView.rowHeight = 64.0f;
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
    
    if (&UIApplicationDidEnterBackgroundNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    self.title = NSLocalizedString(@"BacknumberTitle", nil);
    
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
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    dotImageView.hidden = YES;
    [activityIndicator startAnimating];
    
    loading = YES;
    self.parser = [[[DiaryFeedParser alloc] init] autorelease];
    
	UserSettings *settings = [UserSettings sharedInstance];
	NSString *username = settings.userName;
    
    HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
    self.parser.request = [atomPub makeRequestWithURI:[NSString stringWithFormat:@"http://d.hatena.ne.jp/%@/atom/%@/?page=%d", username, self.isDraft ? @"draft" : @"blog", page] method:@"GET"];
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
    
    DiaryCell *cell = (DiaryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (DiaryCell *)[[[DiaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSUInteger row = indexPath.row;
    
    NSDictionary *entry = [data objectAtIndex:row];
    cell.title = [entry objectForKey:@"title"];
    
    NSString *updated = [entry objectForKey:@"updated"];
    NSRange range = [updated rangeOfString:@"+09:00"];
    if (range.location != NSNotFound) {
        NSDate *date = [dateFormatter1 dateFromString:[updated stringByReplacingCharactersInRange:range withString:@"+0900"]];
        cell.date = [dateFormatter2 stringFromDate:date];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!hasMoreData || loading) {
        return;
    }
    
    NSUInteger row = indexPath.row;
    if (row == [data count] - 1) {
        page++;
        [self loadNextData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    UserSettings *settings = [UserSettings sharedInstance];
	return [NSString stringWithFormat:NSLocalizedString(@"DiaryOf", nil), settings.userName, self.isDraft ? NSLocalizedString(@"DraftSectionTitle", nil) : @""];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    
    NSDictionary *entry = [data objectAtIndex:row];
    
    DiaryViewController *controller = [[DiaryViewController alloc] init];
	controller.titleTextForEdit = [entry objectForKey:@"title"];
	controller.editURI = [entry objectForKey:@"link"];
    if (self.isDraft) {
        controller.isDraft = YES;
        controller.diaryTextForEdit = [entry objectForKey:@"content"];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
        [UIView beginAnimations:nil context:nil];
        blockView.alpha = 1.0f;
        [UIView commitAnimations];
        
        NSUInteger row = self.targetIndexPath.row;
        NSDictionary *entry = [data objectAtIndex:row];
        
        self.uploader = [[[DiaryUploader alloc] init] autorelease];
        self.uploader.delegate = self;
        [self.uploader deleteDiaryWithEditURI:[entry objectForKey:@"link"]];
    } else {
        [listView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.targetIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    [alert dismissWithClickedButtonIndex:0 animated:NO];
    alert = nil;
    
    if (sheet) {
        [listView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.targetIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [sheet dismissWithClickedButtonIndex:1 animated:NO];
        sheet = nil;
    }
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    alert = nil;
}

#pragma mark -

- (void)parser:(DiaryFeedParser *)parser addEntry:(id)entry {
    [data addObject:entry];
    [listView reloadData];
}

- (void)parser:(DiaryFeedParser *)parser encounteredError:(NSError *)error {
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

- (void)parserFinished:(DiaryFeedParser *)p {
    if ([[parser.diaries objectForKey:@"entries"] count] < 20) {
        hasMoreData = NO;
        dotImageView.hidden = NO;
        [activityIndicator stopAnimating];
    }
    
    self.parser = nil;
    
    loading = NO;
    
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
}

#pragma mark -

- (void)diaryUploader:(DiaryUploader *)uploader uploadFinished:(id)responseData {
    [data removeObjectAtIndex:self.targetIndexPath.row];
    [listView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.targetIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    self.uploader = nil;
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 0.0f;
    [UIView commitAnimations];
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
}

- (void)diaryUploader:(DiaryUploader *)diaryUploader uploadFailed:(NSError *)error {
    self.uploader = nil;
    
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
                                           message:[NSString stringWithFormat:@"%@\nStatus Code = %d", [NSHTTPURLResponse localizedStringForStatusCode:uploader.statusCode], uploader.statusCode] 
                                          delegate:self 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
        [alert release];
    }
}

@end
