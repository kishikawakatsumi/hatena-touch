//
//  SettingViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UITableView *listView;
    UITextField *usernameField;
    UITextField *passwordField;
}

@end
