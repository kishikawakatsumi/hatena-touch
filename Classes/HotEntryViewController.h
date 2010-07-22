//
//  HotEntryViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HatenaRSSParser;

@interface HotEntryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *currentData;
    NSMutableDictionary *data;
    NSMutableDictionary *parsers;
    
    UITableView *listView;
    UIImageView *dotImageView;
    UIActivityIndicatorView *activityIndicator;
    UIAlertView *alert;
}

@end
