#import "EntryCell.h"
#import "Debug.h"

@implementation EntryCell

@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize numberLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[self setOpaque:YES];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 5.0f, 277.0f, 36.0f)];
		[titleLabel setOpaque:YES];
		[titleLabel setNumberOfLines:2];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
		[titleLabel setTextColor:[UIColor colorWithRed:0.0f green:0.2f blue:1.0f alpha:1.0f]];
		[titleLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self addSubview:titleLabel];
		
		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 42.0f, 277.0f, 35.0f)];
		[descriptionLabel setOpaque:YES];
		[descriptionLabel setNumberOfLines:2];
		[descriptionLabel setFont:[UIFont systemFontOfSize:12.0f]];
		[descriptionLabel setTextColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
		[descriptionLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self addSubview:descriptionLabel];
		
		numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 16.0f, 21.0f)];
		[numberLabel setOpaque:YES];
		[numberLabel setFont:[UIFont systemFontOfSize:9.0f]];
		[numberLabel setTextAlignment:UITextAlignmentRight];
		[numberLabel setTextColor:[UIColor blackColor]];
		[numberLabel setHighlightedTextColor:[UIColor whiteColor]];
		[self addSubview:numberLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)dealloc {
	LOG_CURRENT_METHOD;
	[titleLabel release];
	[descriptionLabel release];
	[numberLabel release];
	[super dealloc];
}

@end
