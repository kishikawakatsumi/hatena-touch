#import "MyBookmarkNextCell.h"
#import "MyBookmarkNextCellSelectedBackgroundView.h"
#import "TableCellDrawing.h"

@implementation MyBookmarkNextCell

static NSString *cellText;

+ (void)initialize {
	cellText = NSLocalizedString(@"Read Next 20 Entries...", nil);
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        [self setAccessoryType:UITableViewCellAccessoryNone];
		[self setOpaque:YES];
		
		MyBookmarkNextCellSelectedBackgroundView *selectedBackgroundView = [[MyBookmarkNextCellSelectedBackgroundView alloc] initWithFrame:[self frame]];
		[selectedBackgroundView setCell:self];
		[self setSelectedBackgroundView:selectedBackgroundView];
		[selectedBackgroundView release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	[self setNeedsDisplay];
	[self.selectedBackgroundView setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor blackColor] set];
	[cellText drawInRect:CGRectMake(20.0f, 24.0f, 280.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:17.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

- (void)drawSelectedBackgroundRect:(CGRect)rect {
	CGGradientRef gradientForSelected = createTwoColorsGradient(5, 140, 245, 1, 93, 230);
	drawRoundedRectBackgroundGradient(rect, gradientForSelected, NO, NO, NO);
	CGGradientRelease(gradientForSelected);
	[[UIColor whiteColor] set];
	[cellText drawInRect:CGRectMake(20.0f, 24.0f, 280.0f, 21.0f) withFont:[UIFont boldSystemFontOfSize:17.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

- (void)dealloc {
	[super dealloc];
}

@end
