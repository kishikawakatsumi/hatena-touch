//
//  EntryCellSelectedBackgroundView.m
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/07/06.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "EntryCellSelectedBackgroundView.h"
#import "EntryCell.h"

@implementation EntryCellSelectedBackgroundView

@synthesize cell;

- (void)drawRect:(CGRect)rect {
    [cell drawSelectedBackgroundRect:rect];
}

- (void)dealloc {
    [super dealloc];
}

@end
