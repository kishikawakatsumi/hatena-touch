//
//  HotEntryCell.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "EntryCell.h"

static UIColor *blueColor;
static UIColor *grayColor;
static UIColor *darkGrayColor;

static UIFont *titleFont;
static UIFont *descriptionFont;

@interface EntryCellContentView : UIView {
    EntryCell *cell;
    BOOL highlighted;
}

@end

@implementation EntryCellContentView

+ (void)initialize {
	blueColor = [[UIColor colorWithRed:0.0f green:0.2f blue:1.0f alpha:1.0f] retain];
	grayColor = [[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f] retain];
	darkGrayColor = [[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] retain];
    
    titleFont = [[UIFont boldSystemFontOfSize:14.0f] retain];
    descriptionFont = [[UIFont systemFontOfSize:13.0f] retain];
}

- (id)initWithFrame:(CGRect)frame cell:(EntryCell *)tableCell {
    self = [super initWithFrame:frame];
    if (self) {
        cell = tableCell;
        self.opaque = YES;
        self.backgroundColor = cell.backgroundColor;
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    highlighted ? [[UIColor whiteColor] set] : [blueColor set];
	[cell.title drawInRect:CGRectMake(14.0f, 4.0f, cell.frame.size.width - 44.0f, 36.0f) withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
    
    highlighted ? [[UIColor whiteColor] set] : [darkGrayColor set];
	[cell.description drawInRect:CGRectMake(14.0f, 42.0f, cell.frame.size.width - 44.0f, 36.0f) withFont:descriptionFont lineBreakMode:UILineBreakModeTailTruncation];
}

- (void)setHighlighted:(BOOL)b {
    highlighted = b;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted {
    return highlighted;
}

@end

@implementation EntryCell

@synthesize title;
@synthesize link;
@synthesize description;
@synthesize date;
@synthesize subject;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellContentView = [[EntryCellContentView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 0.0f, 1.0f) cell:self];
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeRedraw;
        [self.contentView addSubview:cellContentView];
        [cellContentView release];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [UIView setAnimationsEnabled:NO];
    CGSize contentSize = cellContentView.bounds.size;
    cellContentView.contentStretch = CGRectMake(225.0f / contentSize.width, 0.0f, (contentSize.width - 260.0f) / contentSize.width, 1.0f);
    [UIView setAnimationsEnabled:YES];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    cellContentView.backgroundColor = backgroundColor;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [cellContentView setNeedsDisplay];
}

- (void)dealloc {
    self.title = nil;
    self.link = nil;
    self.description = nil;
    self.date = nil;
    self.subject = nil;
    [super dealloc];
}

@end
