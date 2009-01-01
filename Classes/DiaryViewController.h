#import <UIKit/UIKit.h>
#import "Diary.h"


@interface DiaryViewController : UITableViewController <UITableViewDataSource , UITextFieldDelegate, UITextViewDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	UITableView *diaryView;
	UISegmentedControl *toolButtons;
	
	NSString *editURI;
	BOOL editEntry;
	BOOL editDraft;
	NSString *titleTextForEdit;
	NSString *diaryTextForEdit;
	
	Diary *edittingDiary;
	NSString *dataFilePath;
	BOOL shoudSaveOnExit;
	
	BOOL isEdittingDiaryText;
	
	NSRange currentRange;
}

@property (nonatomic, retain) UITableView *diaryView;
@property (nonatomic, retain) UISegmentedControl *toolButtons;

@property (nonatomic, retain) NSString *editURI;
@property (nonatomic) BOOL editEntry;
@property (nonatomic) BOOL editDraft;
@property (nonatomic, retain) NSString *titleTextForEdit;
@property (nonatomic, retain) NSString *diaryTextForEdit;
@property (nonatomic, retain) Diary *edittingDiary;
@property (nonatomic, retain) NSString *dataFilePath;

- (void)done:(id)sender;
- (void)submit:(id)sender;
- (void)submitDraft:(id)sender;

- (void)showSyntaxList:(id)sender;
- (void)inssertSyntaxText:(NSString *)syntax;

@end
