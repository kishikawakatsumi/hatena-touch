#import "PageInformationCell.h"
#import "TableCellDrawing.h"

@implementation PageInformationCell

@synthesize commentText;
@synthesize userText;
@synthesize numberText;

- (void)setCommentText:(NSString *)text {
	if (commentText != text) {
		[commentText release];
		commentText = [text retain];
		[self setNeedsDisplay];
	}
}

- (void)setUserText:(NSString *)text {
	if (userText != text) {
		[userText release];
		userText = [text retain];
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
        [self setAccessoryType:UITableViewCellAccessoryNone];
		[self setOpaque:YES];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if ([commentText length] > 0) {
		[[UIColor blackColor] set];
		[commentText drawInRect:CGRectMake(20.0f, 1.0f, 280.0f, 74.0f) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeTailTruncation];
		[numberText drawInRect:CGRectMake(0.0f, 35.0f, 16.0f, 21.0f) withFont:[UIFont systemFontOfSize:9.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
		[[UIColor grayColor] set];
		[userText drawInRect:CGRectMake(20.0f, 69.0f, 280.0f, 20.0f) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
	} else {
		[[UIColor blackColor] set];
		[numberText drawInRect:CGRectMake(0.0, 1.0, 16.0, 18.0) withFont:[UIFont systemFontOfSize:9.0f] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
		[[UIColor grayColor] set];
		[userText drawInRect:CGRectMake(20.0, 1.0, 280.0f, 18.0f) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
	}
}

- (void)dealloc {
	[commentText release];
	[userText release];
	[numberText release];
	[super dealloc];
}

@end
