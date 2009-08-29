//
//  MyBookmarkCellSelectedBackgroundView.h
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/08/30.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyBookmarkCell;

@interface MyBookmarkCellSelectedBackgroundView : UITableViewCell {
	MyBookmarkCell *cell;
}

@property (nonatomic, assign) MyBookmarkCell *cell;

@end
