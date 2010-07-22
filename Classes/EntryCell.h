//
//  HotEntryCell.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntryCell : UITableViewCell {
    UIView *cellContentView;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *subject;

@end
