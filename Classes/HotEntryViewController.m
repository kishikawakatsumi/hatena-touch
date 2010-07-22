//
//  HotEntryViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "HotEntryViewController.h"
#import "WebViewController.h"
#import "EntryCell.h"
#import "HatenaRSSParser.h"
#import "UserSettings.h"
#import "NetworkActivityManager.h"
#import "InternetReachability.h"

static NSArray *feedURLs;

@implementation HotEntryViewController

+ (void)initialize {
    feedURLs = [[NSArray arrayWithObjects:
                 @"http://b.hatena.ne.jp/hotentry.rss",
                 @"http://b.hatena.ne.jp/hotentry.rss?mode=general",
                 @"http://b.hatena.ne.jp/hotentry/social.rss",
                 @"http://b.hatena.ne.jp/hotentry/economics.rss",
                 @"http://b.hatena.ne.jp/hotentry/life.rss",
                 @"http://b.hatena.ne.jp/hotentry/entertainment.rss",
                 @"http://b.hatena.ne.jp/hotentry/knowledge.rss",
                 @"http://b.hatena.ne.jp/hotentry/it.rss",
                 @"http://b.hatena.ne.jp/hotentry/game.rss",
                 @"http://b.hatena.ne.jp/hotentry/fun.rss",
                 @"http://b.hatena.ne.jp/video.rss", nil] retain];
}

- (id)init {
    if (self = [super init]) {
        data = [[NSMutableDictionary alloc] initWithCapacity:[feedURLs count]];
        parsers = [[NSMutableDictionary alloc] initWithCapacity:[feedURLs count]];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    [data release];
    for (HatenaRSSParser *parser in [parsers allValues]) {
        parser.delegate = nil;
    }
    [parsers release];
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted-pattern.png"]];
    self.view = contentView;
    [contentView release];
    
    UIScrollView *tabScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 43.0f)];
    tabScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tabScrollView.backgroundColor = [UIColor clearColor];
    tabScrollView.showsVerticalScrollIndicator = NO;
    tabScrollView.showsHorizontalScrollIndicator = NO;
    [contentView addSubview:tabScrollView];
    [tabScrollView release];
    
    UISegmentedControl *categoryControl = [[UISegmentedControl alloc] initWithItems:
                                           [NSArray arrayWithObjects:
                                            NSLocalizedString(@"All", nil), 
                                            NSLocalizedString(@"General", nil), 
                                            NSLocalizedString(@"Social", nil),
                                            NSLocalizedString(@"Economics", nil),
                                            NSLocalizedString(@"Life", nil),
                                            NSLocalizedString(@"Entertainment", nil),
                                            NSLocalizedString(@"Knowledge", nil),
                                            NSLocalizedString(@"IT", nil),
                                            NSLocalizedString(@"Game", nil),
                                            NSLocalizedString(@"Fun", nil),
                                            NSLocalizedString(@"Video", nil), nil]];
    categoryControl.segmentedControlStyle = UISegmentedControlStyleBar;
    categoryControl.frame = CGRectMake(2.0f, 6.0f, categoryControl.frame.size.width, categoryControl.frame.size.height);
    [categoryControl addTarget:self action:@selector(cateoryChanged:) forControlEvents:UIControlEventValueChanged];
    categoryControl.selectedSegmentIndex = 0;
    [tabScrollView addSubview:categoryControl];
    [categoryControl release];
    
    tabScrollView.contentSize = CGSizeMake(categoryControl.frame.size.width + 4.0f, tabScrollView.frame.size.height);
    
    listView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, 320.0f, 373.0f)];
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.title = NSLocalizedString(@"HotEntry", nil);
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
                                          [UIImage imageNamed:@"arrow_left_small.png"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:nil 
                                                                         action:nil];
    [self.navigationItem setBackBarButtonItem:backBarButtonItem];
    [backBarButtonItem release];
    
    [activityIndicator startAnimating];
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

#pragma mark -

- (void)cateoryChanged:(id)sender {
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
    
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSInteger index = control.selectedSegmentIndex;
    
    NSString *URL = [feedURLs objectAtIndex:index];
    if ((currentData = [data objectForKey:URL]) != nil) {
        [listView reloadData];
        return;
    }
    
    currentData = [NSMutableArray arrayWithCapacity:30]; 
    [data setObject:currentData forKey:URL];
    
    [listView reloadData];
    
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    dotImageView.hidden = YES;
    [activityIndicator startAnimating];
    
    HatenaRSSParser *parser = [[HatenaRSSParser alloc] initWithURL:[NSURL URLWithString:URL]];
    [parsers setObject:parser forKey:URL];
    [parser release];
    
    parser.delegate = self;
    [parser parse];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    EntryCell *cell = (EntryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSUInteger row = indexPath.row;
    
    NSDictionary *item = [currentData objectAtIndex:row];
    cell.title = [item objectForKey:@"title"];
    cell.description = [item objectForKey:@"description"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    
    NSDictionary *item = [currentData objectAtIndex:row];
    
    WebViewController *controller = [[WebViewController alloc] init];
    controller.pageURL = [item objectForKey:@"link"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark -

- (void)parser:(HatenaRSSParser *)parser addEntry:(id)entry {
    NSMutableArray *entries = [data objectForKey:parser.identifier];
    [entries addObject:entry];
    
    [listView reloadData];
}

- (void)parser:(HatenaRSSParser *)parser encounteredError:(NSError *)error {
    [parsers removeObjectForKey:parser.identifier];
    
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

- (void)parserFinished:(HatenaRSSParser *)parser {
    [parsers removeObjectForKey:parser.identifier];
    
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    dotImageView.hidden = NO;
    [activityIndicator stopAnimating];
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
