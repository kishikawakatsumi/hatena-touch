//
//  DiaryNextCellSelectedBackgroundView.h
//  HatenaTouch
//
//  Created by KISHIKAWA Katsumi on 09/08/30.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiaryNextCell;

@interface DiaryNextCellSelectedBackgroundView : UIView {
	DiaryNextCell *cell;
}

@property (nonatomic, assign) DiaryNextCell *cell;

@end
