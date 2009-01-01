#import <UIKit/UIKit.h>

@interface DiaryListCell : UITableViewCell {
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *numberLabel;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *numberLabel;

@end
