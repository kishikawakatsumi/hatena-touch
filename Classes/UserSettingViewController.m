#import "UserSettingViewController.h"
#import "UserSettings.h"
#import "HatenaTouchAppDelegate.h"

@implementation UserSettingViewController

@synthesize userSettingView;

- (void)dealloc {
	[userSettingView setDelegate:nil];
	[userSettingView release];
	[super dealloc];
}

- (NSString *)textAtFieldForRow:(NSInteger)row inSection:(NSInteger)section {
	UITableViewCell *cell = [userSettingView cellForRowAtIndexPath:
							 [NSIndexPath indexPathForRow:row inSection:section]];
	return [[[cell subviews] objectAtIndex:2] text];
}

- (void)saveSettings {
	UserSettings *userSettings = [[UserSettings alloc] init];
	userSettings.userName = [self textAtFieldForRow:0 inSection:0];
	userSettings.password = [self textAtFieldForRow:0 inSection:1];
	
	UITableViewCell *cell = [userSettingView cellForRowAtIndexPath:
							 [NSIndexPath indexPathForRow:0 inSection:2]];
	UISegmentedControl *imageSizeSelector = [[cell subviews] objectAtIndex:2]; 
	userSettings.imageSize = [imageSizeSelector selectedSegmentIndex];
	
	cell = [userSettingView cellForRowAtIndexPath:
							 [NSIndexPath indexPathForRow:0 inSection:3]];
	UISwitch *useMobileProxy = [[cell subviews] objectAtIndex:3]; 
	userSettings.useMobileProxy = [useMobileProxy isOn];
	
	cell = [userSettingView cellForRowAtIndexPath:
			[NSIndexPath indexPathForRow:1 inSection:3]];
	UISwitch *shouldAutoRotation = [[cell subviews] objectAtIndex:3]; 
	userSettings.shouldAutoRotation = [shouldAutoRotation isOn];
	
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	hatenaTouchApp.userSettings = userSettings;
	[hatenaTouchApp saveUserSettings];
	[userSettings release];
}

#pragma mark <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0 || section == 1 || section == 2) {
		return 1;
	} else {
		return 2;
	}

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 40.0;
	} else {
		return 30.0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return 0.0;
	} else {
		return 0.0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"UserName", nil);
	} else if (section == 1) {
		return NSLocalizedString(@"Password", nil);
	} else if (section == 2) {
		return NSLocalizedString(@"ImageSize", nil);
	} else {
		return NSLocalizedString(@"WebView", nil);
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	
	if (indexPath.section == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserNameCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserNameCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			[nameField setDelegate:self];
			
			[nameField setAdjustsFontSizeToFitWidth:NO];
			[nameField setBorderStyle:UITextBorderStyleNone];
			[nameField setClearButtonMode:UITextFieldViewModeAlways];
			[nameField setClearsOnBeginEditing:NO];
			[nameField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[nameField setAutocorrectionType:UITextAutocorrectionTypeNo];
			[nameField setEnablesReturnKeyAutomatically:YES];
			[nameField setReturnKeyType:UIReturnKeyNext];
			[nameField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[nameField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			
			[nameField setPlaceholder:NSLocalizedString(@"UserName", nil)];
			[nameField setKeyboardType:UIKeyboardTypeDefault];
			[nameField setText:userSettings.userName];
			
			[cell addSubview:nameField];
			[nameField release];
		}
		
		return cell;
	} else if (indexPath.section == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasseordCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"PasseordCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			[passwordField setDelegate:self];
			
			[passwordField setAdjustsFontSizeToFitWidth:NO];
			[passwordField setBorderStyle:UITextBorderStyleNone];
			[passwordField setClearButtonMode:UITextFieldViewModeAlways];
			[passwordField setClearsOnBeginEditing:NO];
			[passwordField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];
			[passwordField setEnablesReturnKeyAutomatically:YES];
			[passwordField setReturnKeyType:UIReturnKeyDone];
			[passwordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[passwordField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			
			[passwordField setPlaceholder:NSLocalizedString(@"Password", nil)];
			[passwordField setKeyboardType:UIKeyboardTypeDefault];
			[passwordField setSecureTextEntry:YES];
			[passwordField setText:userSettings.password];
			
			[cell addSubview:passwordField];
			[passwordField release];
		}
		
		return cell;
	} else if (indexPath.section == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageSizeCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ImageSizeCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			UISegmentedControl *imageSizeSelector = [[[UISegmentedControl alloc]
													  initWithItems:[NSArray arrayWithObjects:@"S", @"M", @"L", @"XL", nil]] autorelease];
			[imageSizeSelector setFrame:CGRectMake(9.0f, 0.0f, 302.0f, 45.0f)];
			[imageSizeSelector setSelectedSegmentIndex:userSettings.imageSize];
			[cell addSubview:imageSizeSelector];
		}
		
		return cell;
	} else if (indexPath.section == 3 && indexPath.row == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UseMobileProxyCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UseMobileProxyCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 178.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:14]];
			[description setText:NSLocalizedString(@"UseMobileProxy", nil)];
			
			[description release];
			
			UISwitch *useMobileProxy = [[[UISwitch alloc] initWithFrame:CGRectMake(206.0, 9.0, 94.0, 27.0)] autorelease];
			[useMobileProxy setOn:userSettings.useMobileProxy];
			[cell addSubview:useMobileProxy];
		}
		
		return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutoRotationCell"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AutoRotationCell"] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, 178.0, 21.0)];
			[cell addSubview:description];
			
			[description setAdjustsFontSizeToFitWidth:NO];
			[description setFont:[UIFont boldSystemFontOfSize:14]];
			[description setText:NSLocalizedString(@"AutoRotation", nil)];
			
			[description release];
			
			UISwitch *shouldAutoRotation = [[[UISwitch alloc] initWithFrame:CGRectMake(206.0, 9.0, 94.0, 27.0)] autorelease];
			[shouldAutoRotation setOn:userSettings.shouldAutoRotation];
			[cell addSubview:shouldAutoRotation];
		}
		
		return cell;
	}
}

#pragma mark <UITextFieldDelegate> Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == nameField) {
		[nameField resignFirstResponder];
		[passwordField becomeFirstResponder];
	} else {
		[textField resignFirstResponder];
	}

	return YES;
}

#pragma mark <UIViewController> Methods

- (void)loadView {
	[userSettingView release];
	userSettingView = nil;
	userSettingView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f) style:UITableViewStyleGrouped];
	[userSettingView setDelegate:self];
	[userSettingView setDataSource:self];
	[userSettingView setScrollEnabled:NO];
	[self setView:userSettingView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	nameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 282, 44)];
	passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 282, 44)];
	self.title = NSLocalizedString(@"Settings", nil);
}

- (void)viewDidDisappear:(BOOL)animated {
	[self saveSettings];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
