//
//  SettingViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "SettingViewController.h"
#import "UserSettings.h"

@implementation SettingViewController

- (void)dealloc {
    [usernameField release];
    [passwordField release];
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    [contentView release];
    
    listView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f) style:UITableViewStyleGrouped];
    listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    listView.delegate = self;
    listView.dataSource = self;
    [contentView addSubview:listView];
    [listView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [listView flashScrollIndicators];
    [listView deselectRowAtIndexPath:[listView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UserSettings *settings = [UserSettings sharedInstance];
    settings.userName = usernameField.text;
    settings.password = passwordField.text;
    
    [UserSettings saveSettings];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    UserSettings *settings = [UserSettings sharedInstance];
    return settings.shouldAutoRotation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Account", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Image Size", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Web", nil);
    } else {
        return NSLocalizedString(@"Auto Rotation", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserSettings *settings = [UserSettings sharedInstance];
    
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (section == 0 && row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UsernameCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UsernameCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 280.0f, 24.0f)];
            usernameField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            usernameField.delegate = self;
            usernameField.adjustsFontSizeToFitWidth = NO;
            usernameField.borderStyle = UITextBorderStyleNone;
            usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
            usernameField.clearsOnBeginEditing = NO;
            usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
            usernameField.enablesReturnKeyAutomatically = YES;
            usernameField.returnKeyType = UIReturnKeyNext;
            usernameField.placeholder = NSLocalizedString(@"Username", nil);
            usernameField.keyboardType = UIKeyboardTypeDefault;
            usernameField.text = settings.userName;
            
            [cell addSubview:usernameField];
        }
        
        return cell;
    } else if (section == 0 && row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasseordCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasseordCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 280.0f, 24.0f)];
            passwordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            passwordField.delegate = self;
            passwordField.adjustsFontSizeToFitWidth = NO;
            passwordField.borderStyle = UITextBorderStyleNone;
            passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
            passwordField.clearsOnBeginEditing = NO;
            passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
            passwordField.enablesReturnKeyAutomatically = YES;
            passwordField.returnKeyType = UIReturnKeyDone;
            passwordField.placeholder = NSLocalizedString(@"Password", nil);
            passwordField.keyboardType = UIKeyboardTypeDefault;
            passwordField.secureTextEntry = YES;
            passwordField.text = settings.password;
            
            [cell addSubview:passwordField];
        }
        
        return cell;
    } else if (section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageSizeCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageSizeCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
            transparentBackground.backgroundColor = [UIColor clearColor];
            cell.backgroundView = transparentBackground;
            [transparentBackground release];
            
            UISegmentedControl *imageSizeSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"S", @"M", @"L", @"XL", NSLocalizedString(@"Original", nil), nil]];
            imageSizeSegment.segmentedControlStyle = UISegmentedControlStyleBar;
            imageSizeSegment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            imageSizeSegment.frame = CGRectMake(9.0f, 7.0f, 302.0f, 30.0f);
            imageSizeSegment.selectedSegmentIndex = settings.imageSize;
            [imageSizeSegment addTarget:self action:@selector(imageSizeChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:imageSizeSegment];
            [imageSizeSegment release];
        }
        
        return cell;
    } else if (section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UseMobilizerCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UseMobilizerCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 178.0f, 21.0f)];
            description.backgroundColor = [UIColor clearColor];
            description.adjustsFontSizeToFitWidth = NO;
            description.font = [UIFont boldSystemFontOfSize:15.0f];
            description.text = NSLocalizedString(@"Use Mobilizer", nil);
            
            [cell addSubview:description];
            [description release];
            
            UISwitch *useMobilizer = [[UISwitch alloc] initWithFrame:CGRectZero];
            useMobilizer.frame = CGRectMake(300.0f - useMobilizer.frame.size.width, 9.0f, useMobilizer.frame.size.width, useMobilizer.frame.size.height);
            useMobilizer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            useMobilizer.on = settings.useMobileProxy;
            [useMobilizer addTarget:self action:@selector(useMobilizerChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:useMobilizer];
            [useMobilizer release];
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutoRotationCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AutoRotationCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 178.0f, 21.0f)];
            description.backgroundColor = [UIColor clearColor];
            description.adjustsFontSizeToFitWidth = NO;
            description.font = [UIFont boldSystemFontOfSize:15.0f];
            description.text = NSLocalizedString(@"Auto Rotation", nil);
            
            [cell addSubview:description];
            [description release];
            
            UISwitch *shouldAutoRotation = [[UISwitch alloc] initWithFrame:CGRectZero];
            shouldAutoRotation.frame = CGRectMake(300.0f - shouldAutoRotation.frame.size.width, 9.0f, shouldAutoRotation.frame.size.width, shouldAutoRotation.frame.size.height);
            shouldAutoRotation.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            shouldAutoRotation.on = settings.shouldAutoRotation;
            [shouldAutoRotation addTarget:self action:@selector(autoRotationChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:shouldAutoRotation];
            [shouldAutoRotation release];
        }
        
        return cell;
    }
}

#pragma mark -

- (void)imageSizeChanged:(id)sender {
    UISegmentedControl *imageSizeSegment = (UISegmentedControl *)sender;
    UserSettings *settings = [UserSettings sharedInstance];
    settings.imageSize = imageSizeSegment.selectedSegmentIndex;
}

- (void)useMobilizerChanged:(id)sender {
    UISwitch *useMobilizer = (UISwitch *)sender;
    UserSettings *settings = [UserSettings sharedInstance];
    settings.useMobileProxy = useMobilizer.on;
}

- (void)autoRotationChanged:(id)sender {
    UISwitch *autoRotation = (UISwitch *)sender;
    UserSettings *settings = [UserSettings sharedInstance];
    settings.shouldAutoRotation = autoRotation.on;
}

#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == usernameField) {
        [listView scrollRectToVisible:CGRectMake(0.0f, 40.0f, listView.frame.size.width, listView.frame.size.height) animated:YES];
    } else {
        [listView scrollRectToVisible:CGRectMake(0.0f, 40.0f, listView.frame.size.width, listView.frame.size.height) animated:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameField) {
        [usernameField resignFirstResponder];
        [passwordField becomeFirstResponder];
    } else {
        [passwordField resignFirstResponder];
    }
    return YES;
}

@end
