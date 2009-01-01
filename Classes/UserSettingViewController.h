#import <UIKit/UIKit.h>

@interface UserSettingViewController : UITableViewController <UITextFieldDelegate> {
	UITableView *userSettingView;
}

@property (nonatomic, retain) UITableView *userSettingView;

@end
