//
//  RootViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/12.
//  Copyright Kishikawa Katsumi 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UITableView *listView;
}

@end
