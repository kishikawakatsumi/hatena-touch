//
//  MyBookmarkCellSelectedBackgroundView.m
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/08/30.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "MyBookmarkCellSelectedBackgroundView.h"
#import "MyBookmarkCell.h"

@implementation MyBookmarkCellSelectedBackgroundView

@synthesize cell;

- (void)drawRect:(CGRect)rect {
    [cell drawSelectedBackgroundRect:rect];
}

- (void)dealloc {
    [super dealloc];
}

@end
