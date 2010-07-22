//
//  HatenaSyntaxCell.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "HatenaSyntaxCell.h"

static UIColor *blackColor;
static UIColor *grayColor;
static UIColor *darkGrayColor;

static UIFont *titleFont;
static UIFont *syntaxFont;
static UIFont *sampleFont;

@interface HatenaSyntaxCellContentView : UIView {
    HatenaSyntaxCell *cell;
    BOOL highlighted;
}

@end

@implementation HatenaSyntaxCellContentView

+ (void)initialize {
    blackColor = [[UIColor blackColor] retain];
    grayColor = [[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f] retain];
    darkGrayColor = [[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f] retain];
    
    titleFont = [[UIFont boldSystemFontOfSize:16.0f] retain];
    syntaxFont = [[UIFont systemFontOfSize:14.0f] retain];
    sampleFont = syntaxFont;
}

- (id)initWithFrame:(CGRect)frame cell:(HatenaSyntaxCell *)tableCell {
    if (self = [super initWithFrame:frame]) {
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
    highlighted ? [[UIColor whiteColor] set] : [blackColor set];
    [cell.title drawInRect:CGRectMake(10.0f, 12.0f, cell.frame.size.width - 20.0f, 20.0f) withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation];
    
    highlighted ? [[UIColor whiteColor] set] : [grayColor set];
    [cell.sample drawInRect:CGRectMake(170.0f, 12.0f, cell.frame.size.width - 170.0f - 10.0f, 18.0f) withFont:syntaxFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
}

- (void)setHighlighted:(BOOL)b {
    highlighted = b;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted {
    return highlighted;
}

@end

@implementation HatenaSyntaxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        cellContentView = [[HatenaSyntaxCellContentView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 0.0f, 1.0f) cell:self];
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

- (void)dealloc {
    self.title = nil;
    self.syntax = nil;
    self.sample = nil;
    [super dealloc];
}

@end
