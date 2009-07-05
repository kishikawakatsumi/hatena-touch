#import <UIKit/UIKit.h>

@interface UserSettingViewController : UITableViewController <UITextFieldDelegate> {
	UITableView *userSettingView;
	UITextField *nameField;
	UITextField *passwordField;
}

@property (nonatomic, retain) UITableView *userSettingView;

@end
