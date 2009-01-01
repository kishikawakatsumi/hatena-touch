#import <UIKit/UIKit.h>

@interface PageBookmarkCell : UITableViewCell {
	IBOutlet UILabel *urlLabel;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *usersLabel;
}

@property (nonatomic, retain) UILabel *urlLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *usersLabel;

@end
