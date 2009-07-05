//
//  EntryCellSelectedBackgroundView.h
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/07/06.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EntryCell;

@interface EntryCellSelectedBackgroundView : UITableViewCell {
	EntryCell *cell;
}

@property (nonatomic, assign) EntryCell *cell;

@end
