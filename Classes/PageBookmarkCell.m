#import "PageBookmarkCell.h"

@implementation PageBookmarkCell

@synthesize urlLabel;
@synthesize descriptionLabel;
@synthesize titleLabel;
@synthesize usersLabel;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)dealloc {
	[urlLabel release];
	[descriptionLabel release];
	[titleLabel release];
	[usersLabel release];
	[super dealloc];
}

@end
