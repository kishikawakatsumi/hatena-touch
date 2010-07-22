    //
//  DiaryViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "DiaryViewController.h"
#import "HatenaSyntaxViewController.h"
#import "ImagePreviewViewController.h"
#import "Diary.h"
#import "HatenaAtomPub.h"
#import "HatenaAtomPubResponseParser.h"
#import "DiaryUploader.h"
#import "FotolifeUploader.h"
#import "UserSettings.h"
#import "NetworkActivityManager.h"
#import "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static inline NSString *getName(const char *hax3d, int length) {
    char name[length + 1];
    
    for (int i = 0; i < length; ++i) {
        char c = hax3d[i];
        name[i] = (c >= 'a' && c <= 'z') ? ((c - 'a' + 13) % 26) + 'a' : ((c - 'A' + 13) % 26) + 'A';
    }
    name[length] = 0;
    
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

@interface DiaryViewController(Private)
- (void)enableUserInteraction;
- (void)disableUserInteraction;
- (void)saveTemporaryDiary;
- (void)loadTemporaryDiary;
@end

@implementation DiaryViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.editingDiary = nil;
    self.editURI = nil;
    self.titleTextForEdit = nil;
    self.diaryTextForEdit = nil;
    self.receivedData = nil;
    
    diaryUploader.delegate = nil;
    [diaryUploader release];
    
    fotolifeUploader.delegate = nil;
    [fotolifeUploader release];
    
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    [contentView release];
    
    rootView = [[UIView alloc] initWithFrame:contentView.frame];
    rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    rootView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:rootView];
    [rootView release];
    
    bodyTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 372.0f)];
    bodyTextView.contentInset = UIEdgeInsetsMake(44.0f, 0.0f, 0.0f, 0.0f);
    bodyTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bodyTextView.delegate = self;
    bodyTextView.font = [UIFont systemFontOfSize:15.0f];
    [rootView addSubview:bodyTextView];
    [bodyTextView release];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 44.0f - 44.0f, 320.0f, 1.0f)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [UIColor colorWithWhite:0.849 alpha:1.000];
    [bodyTextView addSubview:lineView];
    [lineView release];
    
    titleField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 12.0f - 44.0f, 300.0f, 24.0f)];
    titleField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleField.delegate = self;
    titleField.adjustsFontSizeToFitWidth = NO;
    titleField.borderStyle = UITextBorderStyleNone;
    titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    titleField.clearsOnBeginEditing = NO;
    titleField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    titleField.autocorrectionType = UITextAutocorrectionTypeNo;
    titleField.enablesReturnKeyAutomatically = YES;
    titleField.returnKeyType = UIReturnKeyNext;
    titleField.placeholder = NSLocalizedString(@"Title", nil);
    titleField.keyboardType = UIKeyboardTypeDefault;
    [titleField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [bodyTextView addSubview:titleField];
    [titleField release];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 372.0f, 320.0f, 44.0f)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    [contentView addSubview:toolbar];
    [toolbar release];
    
    clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:110 target:self action:@selector(clear:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    submitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(submit:)];
    draftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save Draft", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveDraft:)];
    clearButton.style = UIBarButtonItemStylePlain;

    submitButton.width = 86.0f;
    draftButton.width = 86.0f;
    
    [toolbar setItems:[NSArray arrayWithObjects:clearButton, flexibleSpace, draftButton, submitButton, nil] animated:NO];
    [clearButton release];
    [flexibleSpace release];
    [submitButton release];
    [draftButton release];
    
    blockView = [[UIView alloc] initWithFrame:contentView.frame];
    blockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blockView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    blockView.alpha = 0.0f;
    [contentView addSubview:blockView];
    [blockView release];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    indicatorView.hidesWhenStopped = YES;
    indicatorView.frame = CGRectMake((blockView.frame.size.width - indicatorView.frame.size.width) / 2, (blockView.frame.size.height - toolbar.frame.size.height - indicatorView.frame.size.height) / 2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    [blockView addSubview:indicatorView];
    [indicatorView release];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (blockView.frame.size.height - toolbar.frame.size.height - 40.0f) / 2, 320.0f, 40.0f)];
    messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont systemFontOfSize:16.0f];
    messageLabel.text = NSLocalizedString(@"Faild loading dada.", nil);
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.numberOfLines = 2;
    messageLabel.hidden = YES;
    [blockView addSubview:messageLabel];
    [messageLabel release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSArray *items = nil;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		items = [NSArray arrayWithObjects:
				 [UIImage imageNamed:@"clipboard_small.png"], [UIImage imageNamed:@"images_small.png"], [UIImage imageNamed:@"camera_small.png"], nil];
	} else {
		items = [NSArray arrayWithObjects:[UIImage imageNamed:@"clipboard_small.png"], [UIImage imageNamed:@"images_small.png"], nil];
	}
	segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
    segmentedControl.frame = CGRectMake(segmentedControl.frame.origin.x, segmentedControl.frame.origin.y, segmentedControl.frame.size.width + 16.0f * [items count], segmentedControl.frame.size.height);
	[segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
	[self.navigationItem setTitleView:segmentedControl];
    [segmentedControl release];
    
    if (!initialized) {
        initialized = YES;
        if (self.editURI) {
            if (self.isDraft) {
                // 下書きの編集
                titleField.text = self.titleTextForEdit;
                bodyTextView.text = self.diaryTextForEdit;
            } else {
                // 既存記事の修正
                [self disableUserInteraction];
                
                self.receivedData = [NSMutableData data];
                
                HatenaAtomPub *atomPub = [[HatenaAtomPub alloc] init];
                NSMutableURLRequest *request = [atomPub makeRequestWithURI:self.editURI method:@"GET"];
                
                NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
                [connection start];
                
                [atomPub release];
            }
        } else {
            [self loadTemporaryDiary];
            titleField.text = self.editingDiary.titleText;
            bodyTextView.text = self.editingDiary.diaryText;
            
            shoudSaveOnExit = YES;
        }
    } else {
        [self loadTemporaryDiary];
        titleField.text = self.editingDiary.titleText;
        bodyTextView.text = self.editingDiary.diaryText;
    }
    
    clearButton.enabled = [titleField.text length] > 0 || [bodyTextView.text length] > 0;
    draftButton.enabled = submitButton.enabled = [titleField.text length] > 0 && [bodyTextView.text length] > 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    blockView = nil;
    indicatorView = nil;
    messageLabel = nil;
}

#pragma mark -

- (void)enableUserInteraction {
    self.view; // load view if needed.
    
    segmentedControl.enabled = YES;
    messageLabel.hidden = YES;
    [indicatorView stopAnimating];
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)disableUserInteraction {
    self.view; // load view if needed.
    
    segmentedControl.enabled = NO;
    messageLabel.hidden = YES;
    [indicatorView startAnimating];
    
    [UIView beginAnimations:nil context:nil];
    blockView.alpha = 1.0f;
    [UIView commitAnimations];
}

#pragma mark -

- (void)loadTemporaryDiary {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *path = [documentDirectory stringByAppendingPathComponent:@"Diary.temp"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		NSMutableData *data  = [NSMutableData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		
		self.editingDiary = [decoder decodeObjectForKey:@"diary"];
		
		[decoder finishDecoding];
		[decoder release];
	}
    if (!self.editingDiary) {
		self.editingDiary = [[[Diary alloc] init] autorelease];
    }
}

- (void)saveTemporaryDiary {
	if ([self.titleTextForEdit length] != 0 || [self.diaryTextForEdit length] != 0) {
		//下書き or 過去の日記の修正の場合は保存しない
		return;
	}
    
	self.editingDiary.titleText = titleField.text;
	self.editingDiary.diaryText = bodyTextView.text;
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *path = [documentDirectory stringByAppendingPathComponent:@"Diary.temp"];
	
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	[encoder encodeObject:self.editingDiary forKey:@"diary"];
	[encoder finishEncoding];
	
	[data writeToFile:path atomically:YES];
	[encoder release];
}

- (void)deleteTemporaryDiary {
	//新規投稿が成功したらローカルファイルを消す
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *path = [documentDirectory stringByAppendingPathComponent:@"Diary.temp"];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		BOOL success = [fileManager removeItemAtPath:path error:nil];
		if (success) {
			//終了時に保存しない
			shoudSaveOnExit = NO;
		}
	}
}

#pragma mark -

- (void)submit:(id)sender {
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    
    [self disableUserInteraction];
    
	Diary *diary = [Diary diaryWithTitle:titleField.text text:bodyTextView.text];
    
    diaryUploader = [[DiaryUploader alloc] init];
    diaryUploader.delegate = self;
    
    if (self.isDraft) {
		//下書きを公開
        [diaryUploader publishDraft:diary editURI:self.editURI];
	} else if (self.isDraft) {
		//既存の記事を編集
        [diaryUploader updateDiary:diary editURI:self.editURI];
	} else {
		//新規投稿
        [diaryUploader uploadDiary:diary];
	}
}

- (void)saveDraft:(id)sender {
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    
    [self disableUserInteraction];
    
    Diary *diary = [Diary diaryWithTitle:titleField.text text:bodyTextView.text];
    
    diaryUploader = [[DiaryUploader alloc] init];
    diaryUploader.delegate = self;
	
	if (self.isDraft) {
		//既存の下書きを修正
        [diaryUploader updateDiary:diary editURI:self.editURI];
	} else {
		//新しく下書きを投稿
        [diaryUploader saveDraft:diary];
	}
}

- (void)uploadImage:(UIImage *)image title:(NSString *)title {
    [[NetworkActivityManager sharedInstance] pushActivity:NSStringFromClass([self class])];
    
    [self disableUserInteraction];
    
    fotolifeUploader = [[FotolifeUploader alloc] init];
    fotolifeUploader.delegate = self;
    [fotolifeUploader uploadImage:image title:title];
}

- (void)insertSyntax:(NSString *)syntax {
	id newText = [NSMutableString stringWithString:bodyTextView.text];
    if ([newText length] == 0) {
        newText = syntax;
    } else {
        [newText insertString:syntax atIndex:selectedRange.location];
    }
    bodyTextView.text = newText;
}

#pragma mark -

- (void)showSyntaxList:(id)sender {    
    HatenaSyntaxViewController *controller = [[HatenaSyntaxViewController alloc] init];
    controller.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentModalViewController:navigationController animated:YES];
    
    [controller release];
    [navigationController release];
}

- (void)showCameraPicker:(id)sender {
    pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    if ([pickerController respondsToSelector:@selector(allowsEditing)]) {
        pickerController.allowsEditing = NO;
    } else {
        pickerController.allowsImageEditing = NO;
    }
	pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}

- (void)showAlbumPicker:(id)sender {
	pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    if ([pickerController respondsToSelector:@selector(allowsEditing)]) {
        pickerController.allowsEditing = NO;
    } else {
        pickerController.allowsImageEditing = NO;
    }
	pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}

- (void)segmentedControlAction:(id)sender {
    selectedRange = bodyTextView.selectedRange;
    
    if ([titleField isFirstResponder]) {
        [titleField resignFirstResponder];
    }
    if ([bodyTextView isFirstResponder]) {
        [bodyTextView resignFirstResponder];
    }
    
    NSInteger index = segmentedControl.selectedSegmentIndex;
	if (index == 0) {
		[self showSyntaxList:sender];
	} else if (index == 1) {
		[self showAlbumPicker:sender];
	} else {
		[self showCameraPicker:sender];
	}
}

- (void)hatenaSyntaxViewController:(HatenaSyntaxViewController *)controller didSelectSyntax:(NSString *)syntax {
    [self insertSyntax:syntax];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissModalViewControllerAnimated:YES];
        pickerController = nil;
        
        UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, nil);
        [self uploadImage:originalImage title:@""];
	} else {
        ImagePreviewViewController *controller = [[ImagePreviewViewController alloc] init];
        controller.delegate = self;
        controller.image = originalImage;
        
        [picker pushViewController:controller animated:YES];
        [controller release];
    }

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
    pickerController = nil;
}

- (void)imagePreviewControllerDidFinishPickingMedia:(ImagePreviewViewController *)controller {
    UIImage *originalImage = controller.image;
    
    [self uploadImage:originalImage title:@""];
    
    [pickerController dismissModalViewControllerAnimated:YES];
    pickerController = nil;
}

- (void)imagePreviewControllerDidCancel:(ImagePreviewViewController *)controller {
    [pickerController dismissModalViewControllerAnimated:YES];
    pickerController = nil;
}

#pragma mark -

- (void)done:(id)sender {
    if ([titleField isFirstResponder]) {
        [titleField resignFirstResponder];
    }
    if ([bodyTextView isFirstResponder]) {
        [bodyTextView resignFirstResponder];
    }
}

- (void)clear:(id)sender {
    NSString *filterClass = getName([@"PNSvygre" cStringUsingEncoding:NSUTF8StringEncoding], 8);
    NSString *filterName = getName([@"fhpxRssrpg" cStringUsingEncoding:NSUTF8StringEncoding], 10);
    NSString *selectorName = getName([@"svygreJvguAnzr" cStringUsingEncoding:NSUTF8StringEncoding], 14);
    
    CATransition *transition = [CATransition animation];
    transition.type = filterName;
    transition.duration = 0.5;
    
    UIView *buttonView = [clearButton valueForKey:@"_view"];
    CGRect buttonFrame = [buttonView convertRect:buttonView.frame toView:self.view];
    
    id filter = [NSClassFromString(filterClass) performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:", selectorName]) withObject:filterName];
    [filter setValue:[NSValue valueWithCGPoint:CGPointMake(buttonFrame.origin.x, buttonFrame.origin.y)] forKey:@"inputPosition"];
    transition.filter = filter;
    
    [rootView.layer addAnimation:transition forKey:nil];
    
    titleField.text = nil;
    bodyTextView.text = nil;
    
    clearButton.enabled = [titleField.text length] > 0 || [bodyTextView.text length] > 0;
    draftButton.enabled = submitButton.enabled = [titleField.text length] > 0 && [bodyTextView.text length] > 0;
}

#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGFloat keyboardTop = self.view.frame.size.height - keyboardRect.size.height;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    bodyTextView.frame = CGRectMake(bodyTextView.frame.origin.x, bodyTextView.frame.origin.y, bodyTextView.frame.size.width, keyboardTop);
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    bodyTextView.frame = CGRectMake(bodyTextView.frame.origin.x, bodyTextView.frame.origin.y, bodyTextView.frame.size.width, self.view.frame.size.height - toolbar.frame.size.height);
    
    [UIView commitAnimations];
}

#pragma mark -

- (void)textFieldChanged:(id)sender {
    clearButton.enabled = [titleField.text length] > 0 || [bodyTextView.text length] > 0;
    draftButton.enabled = submitButton.enabled = [titleField.text length] > 0 && [bodyTextView.text length] > 0;
    
	[self saveTemporaryDiary];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [bodyTextView becomeFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
    [doneButton release];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
}

- (void)textViewDidChange:(UITextView *)textView {
    selectedRange = textView.selectedRange;
    
    clearButton.enabled = [titleField.text length] > 0 || [bodyTextView.text length] > 0;
    draftButton.enabled = submitButton.enabled = [titleField.text length] > 0 && [bodyTextView.text length] > 0;
    
	[self saveTemporaryDiary];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
    [doneButton release];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    statusCode = [(NSHTTPURLResponse *)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    segmentedControl.enabled = NO;
    messageLabel.hidden = NO;
    messageLabel.text = [error localizedDescription];
    [indicatorView stopAnimating];
    
    self.receivedData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (statusCode == 200) {
        responseParser = [[HatenaAtomPubResponseParser alloc] init];
        responseParser.delegate = self;
        [responseParser parseWithData:self.receivedData];
    } else {
        segmentedControl.enabled = NO;
        messageLabel.hidden = NO;
        messageLabel.text = [NSString stringWithFormat:@"%@\nStatus Code = %d", [NSHTTPURLResponse localizedStringForStatusCode:statusCode], statusCode];
        [indicatorView stopAnimating];
    }
    self.receivedData = nil;
}

#pragma mark -

- (void)parserFinished:(HatenaAtomPubResponseParser *)parser {
    titleField.text = self.titleTextForEdit;
    bodyTextView.text = [NSString stringWithFormat:@"[%@]\n", [parser.entry objectForKey:@"syntax"]];
    
    clearButton.enabled = [titleField.text length] > 0 || [bodyTextView.text length] > 0;
    draftButton.enabled = submitButton.enabled = [titleField.text length] > 0 && [bodyTextView.text length] > 0;
    
    [parser release];
    
    [self enableUserInteraction];
}

- (void)parser:(HatenaAtomPubResponseParser *)parser encounteredError:(NSError *)error {
    [parser release];
    
    [self enableUserInteraction];
}

#pragma mark -

- (void)diaryUploader:(DiaryUploader *)uploader uploadFinished:(id)responseData {
    [self enableUserInteraction];
    
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    [self deleteTemporaryDiary];
    [self.navigationController popViewControllerAnimated:YES];
    
    diaryUploader.delegate = nil;
    [diaryUploader release];
    diaryUploader = nil;
}

- (void)diaryUploader:(DiaryUploader *)uploader uploadFailed:(NSError *)error {
    NSLog(@"%s", __func__);
    [self enableUserInteraction];
    
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
    
    diaryUploader.delegate = nil;
    [diaryUploader release];
    diaryUploader = nil;
}

#pragma mark -

- (void)imageUploader:(FotolifeUploader *)uploader uploadFinished:(id)responseData {
    [self insertSyntax:[responseData objectForKey:@"syntax"]];
    
    [self enableUserInteraction];
    
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    fotolifeUploader.delegate = nil;
    [fotolifeUploader release];
    fotolifeUploader = nil;
}

- (void)imageUploader:(FotolifeUploader *)uploader uploadFailed:(NSError *)error {
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppName", nil) 
                                       message:[NSString stringWithFormat:@"%@\nStatus Code = %d", [NSHTTPURLResponse localizedStringForStatusCode:uploader.statusCode], uploader.statusCode] 
                                      delegate:self 
                             cancelButtonTitle:nil 
                             otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
    [alert release];
    
    [self enableUserInteraction];
    
    [[NetworkActivityManager sharedInstance] popActivity:NSStringFromClass([self class])];
    
    fotolifeUploader.delegate = nil;
    [fotolifeUploader release];
    fotolifeUploader = nil;
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
