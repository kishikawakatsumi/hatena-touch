#import "EntryCell.h"
#import "EntryCellSelectedBackgroundView.h"
#import "TableCellDrawing.h"
#import "Debug.h"

@implementation EntryCell

@synthesize titleText;
@synthesize descriptionText;
@synthesize numberText;
@synthesize hasRead;

static UIColor *blueColor = NULL;
static UIColor *grayColor = NULL;
static UIColor *darkGrayColor = NULL;

+ (void)initialize {
	blueColor = [[UIColor colorWithRed:0.0f green:0.2f blue:1.0f alpha:1.0f] retain];
	grayColor = [[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f] retain];
	darkGrayColor = [[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] retain];
}

- (void)setTitleText:(NSString *)text {
	if (titleText != text) {
		[titleText release];
		titleText = [text retain];
		[self setNeedsDisplay];
	}
}

- (void)setDescriptionText:(NSString *)text {
	if (descriptionText != text) {
		[descriptionText release];
		descriptionText = [text retain];
		[self setNeedsDisplay];
	}
}

- (void)setNumberText:(NSString *)text {
	if (numberText != text) {
		[numberText release];
		numberText = [text retain];
		[self setNeedsDisplay];
	}
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[self setOpaque:YES];
		
		EntryCellSelectedBackgroundView *selectedBackgroundView = [[EntryCellSelectedBackgroundView alloc] initWithFrame:[self frame]];
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
	if (hasRead) {
		[grayColor set];
	} else {
		[blueColor set];
	}
	[titleText drawInRect:CGRectMake(20.0f, 5.0f, 277.0f, 36.0f) withFont:[UIFont boldSystemFontOfSize:14.0f] lineBreakMode:UILineBreakModeTailTruncation];
	[darkGrayColor set];
	[descriptionText drawInRect:CGRectMake(20.0f, 42.0f, 277.0f, 35.0f) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeTailTruncation];
	[[UIColor blackColor] set];
	[numberText drawInRect:CGRectMake(0.0f, 30.0f, 16.0f, 21.0f) withFont:[UIFont systemFontOfSize:9.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
}

- (void)drawSelectedBackgroundRect:(CGRect)rect {
	CGGradientRef gradientForSelected = createTwoColorsGradient(5, 140, 245, 1, 93, 230);
	drawRoundedRectBackgroundGradient(rect, gradientForSelected, NO, NO, NO);
	CGGradientRelease(gradientForSelected);
	[[UIColor whiteColor] set];
	[titleText drawInRect:CGRectMake(20.0f, 5.0f, 277.0f, 36.0f) withFont:[UIFont boldSystemFontOfSize:14.0f] lineBreakMode:UILineBreakModeTailTruncation];
	[descriptionText drawInRect:CGRectMake(20.0f, 42.0f, 277.0f, 35.0f) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeTailTruncation];
	[numberText drawInRect:CGRectMake(0.0f, 30.0f, 16.0f, 21.0f) withFont:[UIFont systemFontOfSize:9.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[titleText release];
	[descriptionText release];
	[numberText release];
	[super dealloc];
}

@end
