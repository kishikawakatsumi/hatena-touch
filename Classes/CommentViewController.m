    //
//  CommentViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/13.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentCell.h"
#import "UserSettings.h"

@implementation CommentViewController

- (void)dealloc {
    self.data = nil;
    self.bookmarks = nil;
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    [contentView release];
    
    listView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    listView.delegate = self;
    listView.dataSource = self;
    [contentView addSubview:listView];
    [listView release];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 96.0f)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor whiteColor];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 300.0f, 44.0f)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    titleLabel.numberOfLines = 2;
    [headerView addSubview:titleLabel];
    [titleLabel release];
    
    URLLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 52.0f, 300.0f, 40.0f)];
    URLLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    URLLabel.backgroundColor = [UIColor clearColor];
    URLLabel.font = [UIFont systemFontOfSize:12.0f];
    URLLabel.textColor = [UIColor darkGrayColor];
    URLLabel.numberOfLines = 2;
    URLLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    [headerView addSubview:URLLabel];
    [URLLabel release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookmarks = [self.data objectForKey:@"bookmarks"];
    self.title = [NSString stringWithFormat:@"%d users", [self.bookmarks count]];
    
    NSString *title = [self.data objectForKey:@"title"];
    NSString *URL = [self.data objectForKey:@"url"];
    titleLabel.text = title;
    URLLabel.text = URL;
    
    CGSize size = [title sizeWithFont:titleLabel.font constrainedToSize:titleLabel.frame.size lineBreakMode:UILineBreakModeTailTruncation];
    CGRect titleLabelFrame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, titleLabel.frame.size.width, size.height);
    
    size = [URL sizeWithFont:URLLabel.font constrainedToSize:URLLabel.frame.size lineBreakMode:UILineBreakModeTailTruncation];
    CGRect URLLabelFrame = CGRectMake(URLLabel.frame.origin.x, titleLabelFrame.origin.y + titleLabelFrame.size.height, URLLabel.frame.size.width, size.height);
    
    headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, URLLabelFrame.origin.y + URLLabelFrame.size.height + 8.0f);
    titleLabel.frame = titleLabelFrame;
    URLLabel.frame = URLLabelFrame;
    
    listView.tableHeaderView = headerView;
    [headerView release];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)];
    [self.navigationItem setRightBarButtonItem:closeButton animated:NO];
    [closeButton release];
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
    listView = nil;
}

#pragma mark -

- (void)dismiss:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (CommentCell *)[[[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSUInteger row = indexPath.row;
    
    NSDictionary *bookmark = [self.bookmarks objectAtIndex:row];
    cell.comment = [bookmark objectForKey:@"comment"];
    cell.user = [bookmark objectForKey:@"user"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
	NSString *comment = [[self.bookmarks objectAtIndex:row] objectForKey:@"comment"];
    CGSize size = [comment sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0f, tableView.frame.size.height) lineBreakMode:UILineBreakModeTailTruncation];
	if ([comment length] > 0) {
		return size.height + 4.0f + 20.0f;
	} else {
		return 20.0f;
	}
}

@end
