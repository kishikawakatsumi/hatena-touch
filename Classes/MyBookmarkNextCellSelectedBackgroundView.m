//
//  MyBookmarkNextCellSelectedBackgroundView.m
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/08/30.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "MyBookmarkNextCellSelectedBackgroundView.h"
#import "MyBookmarkNextCell.h"

@implementation MyBookmarkNextCellSelectedBackgroundView

@synthesize cell;

- (void)drawRect:(CGRect)rect {
    [cell drawSelectedBackgroundRect:rect];
}

- (void)dealloc {
    [super dealloc];
}

@end
