#import <UIKit/UIKit.h>

@interface MyBookmarkCell : UITableViewCell {
	NSString *titleText;
	NSString *linkText;
	NSString *numberText;
}

@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *linkText;
@property (nonatomic, retain) NSString *numberText;

- (void)drawSelectedBackgroundRect:(CGRect)rect;

@end
