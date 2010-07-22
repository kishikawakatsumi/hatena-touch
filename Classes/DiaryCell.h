//
//  DiaryCell.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiaryCell : UITableViewCell {
    UIView *cellContentView;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *date;

@end
