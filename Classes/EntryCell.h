#import <UIKit/UIKit.h>

@interface EntryCell : UITableViewCell {
	NSString *titleText;
	NSString *descriptionText;
	NSString *numberText;
	BOOL hasRead;
}

@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSString *numberText;
@property (nonatomic) BOOL hasRead;

- (void)drawSelectedBackgroundRect:(CGRect)rect;

@end
