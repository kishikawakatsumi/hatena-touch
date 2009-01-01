#import <UIKit/UIKit.h>

@interface DiaryCell : UITableViewCell {
	IBOutlet UITextView *diaryTextView;
	IBOutlet UIButton *submitButton;
	IBOutlet UIButton *draftButton;
}

@property (nonatomic, retain) UITextView *diaryTextView;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, retain) UIButton *draftButton;

@end
