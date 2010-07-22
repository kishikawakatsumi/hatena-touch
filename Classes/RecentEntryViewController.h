//
//  RecentEntryViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/13.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentEntryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *currentData;
    NSMutableDictionary *data;
    NSMutableDictionary *parsers;
    
    UITableView *listView;
    UIImageView *dotImageView;
    UIActivityIndicatorView *activityIndicator;
    UIAlertView *alert;
}

@end
