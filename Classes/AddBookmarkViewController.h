#import <UIKit/UIKit.h>

@interface AddBookmarkViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UILabel *urlLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UITextField *commentField;
	IBOutlet UIButton *okButton;
	IBOutlet UIButton *cancelButton;
	NSString *urlString;
	NSString *titleString;
}

@property (nonatomic, retain) UILabel *urlLabel;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UITextField *commentField;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) UIButton *okButton;
@property (nonatomic, retain) UIButton *cancelButton;

- (IBAction)addBookmark:(id)sender;
- (IBAction)cancel:(id)sender;

@end
