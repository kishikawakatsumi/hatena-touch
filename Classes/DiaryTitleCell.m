#import "DiaryTitleCell.h"

@implementation DiaryTitleCell

@synthesize inputField;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)dealloc {
	[inputField setDelegate:nil];
	[inputField release];
	[super dealloc];
}

@end
