//
//  DiaryListViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiaryFeedParser, DiaryUploader;

@interface DiaryListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {    
    NSMutableArray *data;
    NSInteger page;
    BOOL loading;
    BOOL hasMoreData;
    
    UITableView *listView;
    UIView *blockView;
    UIImageView *dotImageView;
    UIActivityIndicatorView *activityIndicator;
    UIActionSheet *sheet;
    UIAlertView *alert;
}

@property (nonatomic, retain) DiaryFeedParser *parser;
@property (nonatomic, retain) DiaryUploader *uploader;
@property (nonatomic, assign) BOOL isDraft;

@property (nonatomic, retain) NSIndexPath *targetIndexPath;

@end
