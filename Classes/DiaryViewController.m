#import "DiaryListViewController.h"
#import "DiaryViewController.h"
#import "Diary.h"
#import "HatenaTouchAppDelegate.h"
#import "HatenaAtomPub.h"
#import "HatenaSyntaxSheetController.h"
#import "Debug.h"

#define DELAY_AFTER_SUBMIT 0.5

@interface DiaryViewController (private)

- (void)inssertSyntaxText:(NSString *)syntax;

@end
	
@implementation DiaryViewController

@synthesize editURI;
@synthesize editEntry;
@synthesize editDraft;
@synthesize titleTextForEdit;
@synthesize diaryTextForEdit;
@synthesize editingDiary;
@synthesize dataFilePath;

- (void)dealloc {
	[toolButtons release];
	[titleField release];
	[bodyView release];
	[draftButton release];
	[submitButton release];
	[dataFilePath release];
	[editURI release];
	[editingDiary release];
	[titleTextForEdit release];
	[diaryTextForEdit release];
	[super dealloc];
}

UIImage *scaleAndRotateImage(UIImage *image, int size) {
	int kMaxResolution = size; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width / height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch (orient) {
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

#pragma mark Temp file access Methods

- (void)loadTemporaryDiary {
    LOG_CURRENT_METHOD;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *path = [documentDirectory stringByAppendingPathComponent:@"Diary.temp"];
	self.dataFilePath = path;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		NSMutableData *theData  = [NSMutableData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
		
		self.editingDiary = [decoder decodeObjectForKey:@"diary"];
		
		[decoder finishDecoding];
		[decoder release];
	} else {
		self.editingDiary = [[Diary alloc] init];
	}
    LOG(@"%@", editingDiary);
}

- (void)saveTemporaryDiary {
    LOG_CURRENT_METHOD;
	if ([titleTextForEdit length] != 0 || [diaryTextForEdit length] != 0) {
		//下書き or 過去の日記の修正の場合は保存しない
		return;
	}
	
	editingDiary.titleText = titleField.text;
	editingDiary.diaryText = bodyView.text;
	
	NSMutableData *theData = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	
	[encoder encodeObject:editingDiary forKey:@"diary"];
	[encoder finishEncoding];
	
	[theData writeToFile:dataFilePath atomically:YES];
	[encoder release];
    
    LOG(@"%@", editingDiary);
}

- (void)deleteTemporaryDiary {
	//新規投稿が成功したらローカルファイルを消す
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:dataFilePath]) {
		BOOL success = [fileManager removeItemAtPath:dataFilePath error:nil];
		if (success) {
			//終了時に保存しない
			shoudSaveOnExit = NO;
		}
	}
}

#pragma mark GUI Methods

- (BOOL)orientationIsPortrait {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		return YES;
	} else {
		return NO;
	}
}

- (void)enableToolButtons:(BOOL)isEnable {	
	for (int i = 0; i < [toolButtons numberOfSegments]; i++) {
		[toolButtons setEnabled:isEnable forSegmentAtIndex:i];
	}
}

- (void)beginEditting {
	UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				 target:self action:@selector(done:)] autorelease];
	[[self navigationItem] setRightBarButtonItem:doneButton animated:YES];
	[[self navigationItem] setHidesBackButton:YES animated:YES];
	
	if (isEdittingDiaryText) {
		[self enableToolButtons:YES];
	}
}

- (void)finishEditting {
	self.navigationItem.rightBarButtonItem = nil;
	[[self navigationItem] setHidesBackButton:NO animated:YES];
	[self enableToolButtons:NO];
	[self saveTemporaryDiary];
}

- (void)enableButtons {
	if ([[titleField text] length] != 0 && [bodyView hasText]) {
		[submitButton setEnabled:YES];
		[draftButton setEnabled:YES];
	} else {
		[submitButton setEnabled:NO];
		[draftButton setEnabled:NO];
	}
}

- (void)moveUpButtons {
	if ([self orientationIsPortrait]) {
        if (IPHONE_OS_VERSION < 3.0) {
            [bodyView setFrame:CGRectMake(0.0f, 40.0f, 320.0f, 160.0f)];
        } else {
            [bodyView setFrame:CGRectMake(0.0f, 40.0f, 320.0f, 160.0f)];
        }
	} else {
        if (IPHONE_OS_VERSION < 3.0) {
            [bodyView setFrame:CGRectMake(0.0, 40.0f, 480.0, 108.0)];
        } else {
            [bodyView setFrame:CGRectMake(0.0, 40.0f, 480.0, 116.0)];
        }
	}
}

- (void)moveDownButtons {
	if ([self orientationIsPortrait]) {
		[bodyView setFrame:CGRectMake(0.0f, 40.0f, 320.0f, 332.0f)];
	} else {
		[bodyView setFrame:CGRectMake(0.0, 40.0f, 480.0, 212.0)];
	}
}

#pragma mark <UITextFieldDelegate> Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self moveUpButtons];
	[self enableButtons];
	[self beginEditting];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([textField.text length] == 1 && range.location == 0 && range.length == 1 && [string length] == 0) {
		[submitButton setEnabled:NO];
		[draftButton setEnabled:NO];
		return YES;
	} 
	if (([textField.text length] != 0 || [string length] != 0)
		&& [[bodyView text] length] != 0) {
		[submitButton setEnabled:YES];
		[draftButton setEnabled:YES];
	} else  {
		[submitButton setEnabled:NO];
		[draftButton setEnabled:NO];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[bodyView becomeFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[self moveDownButtons];
	[self enableButtons];
	[self finishEditting];
	return YES;
}

#pragma mark <UITextViewDelegate> Methods

- (void)textViewDidChange:(UITextView *)textView {
	if ([bodyView.text length] != 0 && [titleField.text length] != 0) {
		[submitButton setEnabled:YES];
		[draftButton setEnabled:YES];
	} else {
		[submitButton setEnabled:NO];
		[draftButton setEnabled:NO];
	}
	[self saveTemporaryDiary];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
	if (!isEdittingDiaryText) {
		isEdittingDiaryText = YES;
		[self moveUpButtons];
		[self enableButtons];
		[self beginEditting];
	}
	currentRange = textView.selectedRange;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text length] == 1 && range.length == 0) {
		currentRange.location = range.location + 1;
	} else if ([text length] != 0) {
		currentRange.location = range.location + range.length;
	} else {
		currentRange = range;
	}
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	isEdittingDiaryText = NO;
	[self moveDownButtons];
	[self enableButtons];
	[self finishEditting];
	return YES;
}

#pragma mark <UIImagePickerControllerDelegate> Methods

- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	HatenaTouchAppDelegate *hatenaTouchApp = [HatenaTouchAppDelegate sharedHatenaTouchApp];
	UserSettings *userSettings = hatenaTouchApp.userSettings;
	NSInteger imageSize = 480;
	switch (userSettings.imageSize) {
		case UserSettingsImageSizeSmall:
			imageSize = 240;
			break;
		case UserSettingsImageSizeMedium:
			imageSize = 480;
			break;
		case UserSettingsImageSizeLarge:
			imageSize = 600;
			break;
		case UserSettingsImageSizeExtraLarge:
			imageSize = 800;
			break;
		default:
			break;
	}
	
	UIImage *originalImage = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];
	UIImage *uploadImage = nil;
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, nil);
		uploadImage = scaleAndRotateImage(originalImage, imageSize);
	} else {
		uploadImage = scaleAndRotateImage(originalImage, imageSize);
	}
	HatenaAtomPub *atomPub = [[[HatenaAtomPub alloc] init] autorelease];
	NSDictionary *responseData = [atomPub requestPostNewImage:uploadImage title:@""];
	if (responseData) {
		[self inssertSyntaxText:[NSString stringWithFormat:@"[%@]\n", [responseData objectForKey:@"hatena:syntax"]]];
	}
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark Action Methods

-(void)done:(id)sender {
	if ([titleField isEditing]) {
		[titleField resignFirstResponder];
	} else {
		[bodyView resignFirstResponder];
	}
}

-(void)showCameraImagePicker:(id)sender {
	UIImagePickerController *pickerController = [[HatenaTouchAppDelegate sharedHatenaTouchApp] sharedPickerController];
	pickerController.allowsImageEditing = YES;
	pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:pickerController animated:YES];
}

-(void)showAlbumImagePicker:(id)sender {
	UIImagePickerController *pickerController = [[HatenaTouchAppDelegate sharedHatenaTouchApp] sharedPickerController];
	pickerController.allowsImageEditing = YES;
	pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:pickerController animated:YES];
}

- (void)segmentAction:(id)sender {
	NSInteger index = [toolButtons selectedSegmentIndex];
	if (index == 0) {
		[self showSyntaxList:sender];
	} else if (index == 1) {
		[self showAlbumImagePicker:sender];
	} else {
		[self showCameraImagePicker:sender];
	}
	
}

- (void)showSyntaxList:(id)sender {
	HatenaSyntaxSheetController *controller = 
	[[[HatenaSyntaxSheetController alloc] initWithNibName:@"HatenaSyntaxSheet" bundle:nil] autorelease];
	self.navigationItem.rightBarButtonItem = nil;
	[self presentModalViewController:controller animated:YES];
}

- (void)inssertSyntaxText:(NSString *)syntax {
	NSMutableString *newText = [NSMutableString stringWithString:bodyView.text];
	[newText insertString:syntax atIndex:currentRange.location];
	[bodyView setText:newText];
}

#pragma mark HTTP request Methods

- (void)_submit {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	Diary *diary = [Diary diaryWithTitle:titleField.text text:bodyView.text];
	
	BOOL success = NO;
	NSString *newPostURL = nil;
	
	if (editEntry) {
		//既存の記事を編集
		success = [atomPub requestEditEntry:diary editURI:editURI];
		NSArray *viewControllers = [[self navigationController] viewControllers];
		DiaryListViewController *controller = [viewControllers objectAtIndex:1];
		controller.forceReload = YES;
	} else if (editDraft) {
		//下書きを公開
		newPostURL = [atomPub requestPostNewEntryFromDraft:diary editURI:editURI];
		NSArray *viewControllers = [[self navigationController] viewControllers];
		DiaryListViewController *controller = [viewControllers objectAtIndex:1];
		controller.forceReload = YES;
	} else {
		//新規投稿
		//下書きを保存する場合は -> submitDraft
		newPostURL = [atomPub requestPostNewEntry:diary];
	}
	
	[atomPub release];
	
	if (success || newPostURL) {
		[self deleteTemporaryDiary];
		[NSThread sleepForTimeInterval:DELAY_AFTER_SUBMIT];
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
	[[[self.view subviews] objectAtIndex:[[self.view subviews] count] - 1] removeFromSuperview];
	
	[pool release];
}

- (void)submit:(id)sender {
	[self done:nil];
	UIView *waitingView = [HatenaAtomPub waitingView];
	[self.view addSubview:waitingView];
	[NSThread detachNewThreadSelector:@selector(_submit) toTarget:self withObject:nil];
}

- (void)_submitDraft {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
	Diary *diary = [Diary diaryWithTitle:titleField.text text:bodyView.text];
	
	BOOL success = NO;
	NSString *newPostURL = nil;
	
	if (editDraft) {
		//既存の下書きを修正
		success = [atomPub requestEditEntry:diary editURI:editURI];
		NSArray *viewControllers = [[self navigationController] viewControllers];
		DiaryListViewController *controller = [viewControllers objectAtIndex:1];
		controller.forceReload = YES;
	} else {
		//新しく下書きを投稿
		newPostURL = [atomPub requestPostNewDraft:diary];
	}
	
	[atomPub release];
	
	if (success || newPostURL) {
		[self deleteTemporaryDiary];
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
	[[[self.view subviews] objectAtIndex:[[self.view subviews] count] - 1] removeFromSuperview];
	
	[pool release];
}

- (void)submitDraft:(id)sender {
	//新しく下書きを保存
	[self done:nil];
	UIView *waitingView = [HatenaAtomPub waitingView];
	[self.view addSubview:waitingView];
	[NSThread detachNewThreadSelector:@selector(_submitDraft) toTarget:self withObject:nil];
}

#pragma mark <UIViewController> Methods

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    LOG_CURRENT_METHOD;
	if ([self orientationIsPortrait]) {
		[submitButton setFrame:CGRectMake(220.0, 376.0, 80.0, 30.0)];
		[draftButton setFrame:CGRectMake(132.0, 376.0, 80.0, 30.0)];
        if (IPHONE_OS_VERSION < 3.0) {
            if (isEdittingDiaryText || [titleField isEditing]) {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 320.0, 164.0f)];
            } else {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 320.0, 332.0)];
            }
        } else {
            if (isEdittingDiaryText || [titleField isEditing]) {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 320.0, 204.0f)];
            } else {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 320.0, 376.0)];
            }
        }
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	} else {
		[submitButton setFrame:CGRectMake(380.0, 264.0, 80.0, 30.0)];
		[draftButton setFrame:CGRectMake(292.0, 264.0, 80.0, 30.0)];
        if (IPHONE_OS_VERSION < 3.0) {
            if (isEdittingDiaryText) {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 480.0, 108.0)];
            } else {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 480.0, 216.0)];
            }
        } else {
            if (isEdittingDiaryText) {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 480.0, 84.0)];
            } else {
                [bodyView setFrame:CGRectMake(0.0, 40.0f, 480.0, 184.0)];
            }
        }
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    contentView.backgroundColor = [UIColor whiteColor];
	[self setView:contentView];
    [contentView release];
	
	titleField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 4.0f, 310.0f, 33.0f)];
	[titleField setDelegate:self];
	[titleField setAdjustsFontSizeToFitWidth:NO];
	[titleField setBorderStyle:UITextBorderStyleNone];
	[titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[titleField setClearsOnBeginEditing:NO];
	[titleField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[titleField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[titleField setEnablesReturnKeyAutomatically:YES];
	[titleField setReturnKeyType:UIReturnKeyNext];
	[titleField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[titleField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[titleField setPlaceholder:NSLocalizedString(@"Title", nil)];
	[titleField setKeyboardType:UIKeyboardTypeDefault];
	[titleField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [contentView addSubview:titleField];
	
	bodyView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, 320.0f, 376.0f)];
	[bodyView setDelegate:self];
	[bodyView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[bodyView setAutocorrectionType:UITextAutocorrectionTypeNo];
	[bodyView setReturnKeyType:UIReturnKeyDefault];
	[bodyView setKeyboardType:UIKeyboardTypeDefault];
	[bodyView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    bodyView.font = [UIFont systemFontOfSize:14.0f];
    [contentView addSubview:bodyView];
	
	draftButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[draftButton setTitle:NSLocalizedString(@"DraftButton", nil) forState:UIControlStateNormal];
	draftButton.frame = CGRectMake(132.0f, 376.0f, 80.0f, 30.0f);
    [contentView addSubview:draftButton];
	
	submitButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[submitButton setTitle:NSLocalizedString(@"SubmitButton", nil) forState:UIControlStateNormal];
	submitButton.frame = CGRectMake(220.0f, 376.0f, 80.0f, 30.0f);
    [contentView addSubview:submitButton];
	
	[draftButton addTarget:self action:@selector(submitDraft:) forControlEvents:UIControlEventTouchUpInside];
	[submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
	[super viewDidLoad];
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	NSArray *items;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		items = [NSArray arrayWithObjects:
				 [UIImage imageNamed:@"Syntax.png"], [UIImage imageNamed:@"Album.png"], [UIImage imageNamed:@"Camera.png"], nil];
	} else {
		items = [NSArray arrayWithObjects:[UIImage imageNamed:@"Syntax.png"], [UIImage imageNamed:@"Album.png"], nil];
	}
	toolButtons = [[UISegmentedControl alloc] initWithItems:items];
	toolButtons.segmentedControlStyle = UISegmentedControlStyleBar;
	toolButtons.selected = NO;
	toolButtons.momentary = YES;
	[toolButtons addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	[[self navigationItem] setTitleView:toolButtons];
	
	UIImagePickerController *pickerController = [[HatenaTouchAppDelegate sharedHatenaTouchApp] sharedPickerController];
	pickerController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
	[super viewWillAppear:animated];
	[self loadTemporaryDiary];
    if (titleTextForEdit) {
        [titleField setText:titleTextForEdit];
    } else {
        [titleField setText:editingDiary.titleText];
    }
    if (editEntry) {
        [draftButton removeFromSuperview];
    }
    if (diaryTextForEdit) {
        [bodyView setText:diaryTextForEdit];
    } else {
        [bodyView setText:editingDiary.diaryText];
    }
	shoudSaveOnExit = YES;
	[self enableToolButtons:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
	[super viewDidAppear:animated];
	[self enableButtons];
	
	[bodyView scrollRangeToVisible:currentRange];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
	if (shoudSaveOnExit) {
		[self saveTemporaryDiary];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
