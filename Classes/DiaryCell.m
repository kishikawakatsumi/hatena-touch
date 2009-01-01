#import "DiaryCell.h"

@implementation DiaryCell

@synthesize diaryTextView;
@synthesize submitButton;
@synthesize draftButton;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)dealloc {
	[draftButton release];
	[submitButton release];
	[diaryTextView setDelegate:nil];
	[diaryTextView release];
	[super dealloc];
}


@end
