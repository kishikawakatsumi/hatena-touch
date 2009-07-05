#import <UIKit/UIKit.h>

@interface PageInformationCell : UITableViewCell {
	NSString *commentText;
	NSString *userText;
	NSString *numberText;
}

@property (nonatomic, retain) NSString *commentText;
@property (nonatomic, retain) NSString *userText;
@property (nonatomic, retain) NSString *numberText;

@end
