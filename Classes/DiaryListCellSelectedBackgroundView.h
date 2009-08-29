//
//  DiaryListCellSelectedBackgroundView.h
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/08/30.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiaryListCell;

@interface DiaryListCellSelectedBackgroundView : UIView {
	DiaryListCell *cell;
}

@property (nonatomic, assign) DiaryListCell *cell;

@end
