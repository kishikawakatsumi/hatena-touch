//
//  RootViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright Kishikawa Katsumi 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface RootViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate> {
    UITableView *listView;
    BOOL iAdIsAvailable;
}

@property (nonatomic, retain) ADBannerView *bannerView;

@end
