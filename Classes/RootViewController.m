#import "RootViewController.h"
#import "HotEntryViewController.h"
#import "MyBookmarkViewController.h"
#import "DiaryViewController.h"
#import "DiaryListViewController.h"
#import "UserSettingViewController.h"
#import "HatenaTouchAppDelegate.h"
#import "Debug.h"

@implementation RootViewController

- (BOOL)hasDoneSettings {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	
	NSString *userName = userSettings.userName;
	NSString *password = userSettings.password;
	
	BOOL done = NO;
	if ([userName length] != 0 && [password length] != 0) {
		done = YES;
	}
	return done;
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 3;
	} else if (section == 1) {
		return 2;
	} else {
		return 2;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"Edit", nil);
	} else if (section == 1) {
		return NSLocalizedString(@"Browse", nil);
	} else {
		return NSLocalizedString(@"HelpAndSettings", nil);
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"MenuListCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
	}
	
	if (indexPath.section == 0 && indexPath.row == 0) {
		cell.text = NSLocalizedString(@"New", nil);
		if ([self hasDoneSettings]) {
			cell.textColor = [UIColor blackColor];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textColor = [UIColor grayColor];
		}
	} else if (indexPath.section == 0 && indexPath.row == 1) {
		cell.text = NSLocalizedString(@"Draft", nil);
		if ([self hasDoneSettings]) {
			cell.textColor = [UIColor blackColor];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textColor = [UIColor grayColor];
		}
	} else if (indexPath.section == 0 && indexPath.row == 2) {
		cell.text = NSLocalizedString(@"Backnumber", nil);
		if ([self hasDoneSettings]) {
			cell.textColor = [UIColor blackColor];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textColor = [UIColor grayColor];
		}
	} else if (indexPath.section == 1 && indexPath.row == 0) {
		cell.text = NSLocalizedString(@"HotEntry", nil);
	} else if (indexPath.section == 1 && indexPath.row == 1) {
		cell.text = NSLocalizedString(@"MyBookmark", nil);
		if ([self hasDoneSettings]) {
			cell.textColor = [UIColor blackColor];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textColor = [UIColor grayColor];
		}
	} else if (indexPath.section == 2 && indexPath.row == 0) {
		cell.text = NSLocalizedString(@"Settings", nil);
	} else if (indexPath.section == 2 && indexPath.row == 1) {
		cell.text = NSLocalizedString(@"Help", nil);
	}
	return cell;
}

#pragma mark <UITableViewDelegate> Methods

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 if ([self hasDoneSettings] && indexPath.section == 0 && indexPath.row == 0) {
		 DiaryViewController *controller = [[DiaryViewController alloc] initWithStyle:UITableViewStylePlain];
		 [[self navigationController] pushViewController:controller animated:YES];
		 [controller release];
	 } else if ([self hasDoneSettings] && indexPath.section == 0 && indexPath.row == 1) {
		 DiaryListViewController *controller = [[DiaryListViewController alloc] initWithStyle:UITableViewStylePlain];
		 controller.title = NSLocalizedString(@"DraftTitle", nil);
		 controller.draft = YES;
		 [[self navigationController] pushViewController:controller animated:YES];
		 [controller release];
	 } else if ([self hasDoneSettings] && indexPath.section == 0 && indexPath.row == 2) {
		 DiaryListViewController *controller = [[DiaryListViewController alloc] initWithStyle:UITableViewStylePlain];
		 controller.title = NSLocalizedString(@"BacknumberTitle", nil);
		 controller.draft = NO;
		 [[self navigationController] pushViewController:controller animated:YES];
		 [controller release];
	 } else if (indexPath.section == 1 && indexPath.row == 0) {
		 HotEntryViewController *controller = [[HotEntryViewController alloc] initWithStyle:UITableViewStylePlain];
		 [[self navigationController] pushViewController:controller animated:YES];
		 [controller release];
	 } else if ([self hasDoneSettings] && indexPath.section == 1 && indexPath.row == 1) {
		 MyBookmarkViewController *controller = [[MyBookmarkViewController alloc] initWithStyle:UITableViewStylePlain];
		 [[self navigationController] pushViewController:controller animated:YES];
		 [controller release];
	 } else if (indexPath.section == 2 && indexPath.row == 0) {
		 UserSettingViewController *controller = [[UserSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
		 [[self navigationController] pushViewController:controller animated:YES];
		 [controller release];
	 } else if (indexPath.section == 2 && indexPath.row == 1) {
		 UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
		 NSBundle *bundle = [NSBundle mainBundle];
		 NSString *helpFilePath = [bundle pathForResource:@"help" ofType:@"html"];
		 NSData *data = [NSData dataWithContentsOfFile:helpFilePath];
		 [webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:helpFilePath]];
		 [webView setDelegate:self];
		 
		 UIViewController *controller = [[UIViewController alloc] init];
		 controller.view = webView;
		 [webView release];
		 
		 [[self navigationController] pushViewController:controller animated:YES];
		 [controller release];
	 }
}

#pragma mark <UIWebViewDelegate> Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - Overridden

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[self tableView] reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	LOG_CURRENT_METHOD;
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[self.tableView setDelegate:nil];
	[super dealloc];
}

@end
