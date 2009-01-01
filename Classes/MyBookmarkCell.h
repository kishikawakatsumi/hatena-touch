#import <UIKit/UIKit.h>

@interface MyBookmarkCell : UITableViewCell {
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *linkLabel;
	IBOutlet UILabel *numberLabel;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *linkLabel;
@property (nonatomic, retain) UILabel *numberLabel;

@end
