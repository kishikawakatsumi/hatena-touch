//
//  CommentCell.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "CommentCell.h"

@interface CommentCellContentView : UIView {
    CommentCell *cell;
    BOOL highlighted;
}

@end

@implementation CommentCellContentView

- (id)initWithFrame:(CGRect)frame cell:(CommentCell *)tableCell {
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
    UIFont *font = [UIFont systemFontOfSize:12.0f];
	if ([cell.comment length] > 0) {
		[[UIColor blackColor] set];
        CGSize size = [cell.comment sizeWithFont:font constrainedToSize:CGSizeMake(cell.frame.size.width - 20.0f, cell.frame.size.height) lineBreakMode:UILineBreakModeTailTruncation];
		[cell.comment drawInRect:CGRectMake(10.0f, 1.0f, cell.frame.size.width - 20.0f, size.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation];
		[[UIColor grayColor] set];
		[cell.user drawInRect:CGRectMake(10.0f, size.height + 4.0f, cell.frame.size.width - 20.0f, 20.0f) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
	} else {
		[[UIColor grayColor] set];
		[cell.user drawInRect:CGRectMake(10.0f, 1.0f, cell.frame.size.width - 20.0f, 18.0f) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
	}
}

- (void)setHighlighted:(BOOL)b {
    highlighted = b;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted {
    return highlighted;
}

@end

@implementation CommentCell

@synthesize comment;
@synthesize user;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellContentView = [[CommentCellContentView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 0.0f, 1.0f) cell:self];
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
    self.comment = nil;
    self.user = nil;
    [super dealloc];
}

@end
