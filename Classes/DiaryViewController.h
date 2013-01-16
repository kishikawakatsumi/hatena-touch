//
//  DiaryViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Diary, DiaryUploader, FotolifeUploader, HatenaAtomPubResponseParser;

@interface DiaryViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, 
UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIView *rootView;
    UITextField *titleField;
    UITextView *bodyTextView;
    
    UISegmentedControl *segmentedControl;
    
    UIBarButtonItem *clearButton;
    UIBarButtonItem *submitButton;
    UIBarButtonItem *draftButton;
    UIToolbar *toolbar;
    
    UIImagePickerController *pickerController;
    
    UIView *blockView;
    UIActivityIndicatorView *indicatorView;
    UILabel *messageLabel;
    
    UIAlertView *alert;
    
    NSRange selectedRange;
    
    DiaryUploader *diaryUploader;
    FotolifeUploader *fotolifeUploader;
    HatenaAtomPubResponseParser *responseParser;
    
    BOOL shoudSaveOnExit;
    
    NSInteger statusCode;
    
    BOOL initialized;
}

@property (nonatomic, retain) Diary *editingDiary;
@property (nonatomic, retain) NSString *editURI;
@property (nonatomic, retain) NSString *titleTextForEdit;
@property (nonatomic, retain) NSString *diaryTextForEdit;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, assign) BOOL isDraft;
@property (nonatomic, retain) NSString *insertText;

@end
