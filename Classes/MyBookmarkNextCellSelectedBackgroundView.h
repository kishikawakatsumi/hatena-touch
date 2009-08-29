//
//  MyBookmarkNextCellSelectedBackgroundView.h
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/08/30.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyBookmarkNextCell;

@interface MyBookmarkNextCellSelectedBackgroundView : UITableViewCell {
	MyBookmarkNextCell *cell;
}

@property (nonatomic, assign) MyBookmarkNextCell *cell;

@end
