//
//  CommentViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/13.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UITableView *listView;
    UIView *headerView;
    UILabel *titleLabel;
    UILabel *URLLabel;
}

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSArray *bookmarks;

@end
