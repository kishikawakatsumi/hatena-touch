#import <UIKit/UIKit.h>

@interface DiaryListCell : UITableViewCell {
	NSString *titleText;
	NSString *dateText;
	NSString *numberText;
}

@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *dateText;
@property (nonatomic, retain) NSString *numberText;

- (void)drawSelectedBackgroundRect:(CGRect)rect;

@end
