#import <UIKit/UIKit.h>

@interface PageInformationCell : UITableViewCell {
	IBOutlet UILabel *commentLabel;
	IBOutlet UILabel *userLabel;
	IBOutlet UILabel *numberLabel;
}

@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) UILabel *userLabel;
@property (nonatomic, retain) UILabel *numberLabel;

@end
