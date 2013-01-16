//
//  RootViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright Kishikawa Katsumi 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DiaryListViewController.h"
#import "DiaryViewController.h"
#import "HotEntryViewController.h"
#import "RecentEntryViewController.h"
#import "MyBookmarkViewController.h"
#import "SettingViewController.h"
#import "HelpViewController.h"
#import "UserSettings.h"

@implementation RootViewController

- (void)dealloc {
    self.bannerView = nil;
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    [contentView release];
    
    listView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    listView.delegate = self;
    listView.dataSource = self;
    [contentView addSubview:listView];
    [listView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"AppName", nil);
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
                                          [UIImage imageNamed:@"arrow_left_small.png"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:nil 
                                                                         action:nil];
    [self.navigationItem setBackBarButtonItem:backBarButtonItem];
    [backBarButtonItem release];
    
    Class clazz = NSClassFromString(@"ADBannerView");
    if (clazz) {
        self.bannerView = [[[ADBannerView alloc] initWithFrame:CGRectZero] autorelease];
        self.bannerView.delegate = self;
        self.bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [listView reloadData];
    [listView flashScrollIndicators];
    [listView deselectRowAtIndexPath:[listView indexPathForSelectedRow] animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    UserSettings *settings = [UserSettings sharedInstance];
    return settings.shouldAutoRotation;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    } else {
        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    }
    listView.tableHeaderView = self.bannerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

#pragma mark -

- (BOOL)hasAccountSettings {
    UserSettings *settings = [UserSettings sharedInstance];
    
    NSString *username = settings.userName;
    NSString *password = settings.password;
    
    BOOL done = NO;
    if ([username length] > 0 && [password length] > 0) {
        done = YES;
    }
    return done;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Edit", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Browse", nil);
    } else {
        return NSLocalizedString(@"HelpAndSettings", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (section == 0 && row == 0) {
        cell.textLabel.text = NSLocalizedString(@"New", nil);
        if ([self hasAccountSettings]) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    } else if (section == 0 && row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Draft", nil);
        if ([self hasAccountSettings]) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    } else if (section == 0 && row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Backnumber", nil);
        if ([self hasAccountSettings]) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    } else if (section == 1 && row == 0) {
        cell.textLabel.text = NSLocalizedString(@"HotEntry", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.textColor = [UIColor blackColor];
    } else if (section == 1 && row == 1) {
        cell.textLabel.text = NSLocalizedString(@"RecentEntry", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.textColor = [UIColor blackColor];
    } else if (section == 1 && row == 2) {
        cell.textLabel.text = NSLocalizedString(@"MyBookmark", nil);
        if ([self hasAccountSettings]) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    } else if (section == 2 && row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Settings", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.textColor = [UIColor blackColor];
    } else if (section == 2 && row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Help", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if ([self hasAccountSettings] && section == 0 && row == 0) {
        DiaryViewController *controller = [[DiaryViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if ([self hasAccountSettings] && section == 0 && row == 1) {
        DiaryListViewController *controller = [[DiaryListViewController alloc] init];
        controller.isDraft = YES;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if ([self hasAccountSettings] && section == 0 && row == 2) {
        DiaryListViewController *controller = [[DiaryListViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if (section == 1 && row == 0) {
        HotEntryViewController *controller = [[HotEntryViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if (section == 1 && row == 1) {
        RecentEntryViewController *controller = [[RecentEntryViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if ([self hasAccountSettings] && section == 1 && row == 2) {
        MyBookmarkViewController *controller = [[MyBookmarkViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if (section == 2 && row == 0) {
        SettingViewController *controller = [[SettingViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if (section == 2 && row == 1) {
        HelpViewController *controller = [[HelpViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}

#pragma mark -

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    listView.tableHeaderView = self.bannerView;
}    

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    listView.tableHeaderView = nil;
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

@end
