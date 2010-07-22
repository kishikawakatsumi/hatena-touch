//
//  MyBookmarkViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyBookmarkFeedParser, MyBookmarkAPI;

@interface MyBookmarkViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, 
UIAlertViewDelegate, UIActionSheetDelegate> {
    NSMutableArray *data;
    NSInteger offset;
    BOOL loading;
    BOOL hasMoreData;
    
    UITableView *listView;
    UIView *blockView;
    UIImageView *dotImageView;
    UIActivityIndicatorView *activityIndicator;
    UIActionSheet *sheet;
    UIAlertView *alert;
}

@property (nonatomic, retain) MyBookmarkFeedParser *parser;
@property (nonatomic, retain) NSIndexPath *targetIndexPath;
@property (nonatomic, retain) MyBookmarkAPI *bookmarkAPI;

@end
