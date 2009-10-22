#import <UIKit/UIKit.h>
#import "Diary.h"

@interface DiaryViewController : UIViewController 
<UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	UITextField *titleField;
	UITextView *bodyView;
	UIButton *draftButton;
	UIButton *submitButton;
	
	UISegmentedControl *toolButtons;
	
	NSString *editURI;
	BOOL editEntry;
	BOOL editDraft;
	NSString *titleTextForEdit;
	NSString *diaryTextForEdit;
	
	Diary *editingDiary;
	NSString *dataFilePath;
	BOOL shoudSaveOnExit;
	
	BOOL isEdittingDiaryText;
	
	NSRange currentRange;
}

@property (nonatomic, retain) NSString *editURI;
@property (nonatomic) BOOL editEntry;
@property (nonatomic) BOOL editDraft;
@property (nonatomic, retain) NSString *titleTextForEdit;
@property (nonatomic, retain) NSString *diaryTextForEdit;
@property (nonatomic, retain) Diary *editingDiary;
@property (nonatomic, retain) NSString *dataFilePath;

- (void)done:(id)sender;
- (void)submit:(id)sender;
- (void)submitDraft:(id)sender;

- (void)showSyntaxList:(id)sender;
- (void)insertSyntaxText:(NSString *)syntax;

@end
