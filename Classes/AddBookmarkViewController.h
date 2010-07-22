//
//  AddBookmarkViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyBookmarkAPI;

@interface AddBookmarkViewController : UIViewController {
    UILabel *titleLabel;
    UILabel *URLLabel;
    UITextField *commentField;
    UIView *blockView;
    UIAlertView *alert;
    MyBookmarkAPI *bookmarkAPI;
}

@property (nonatomic, retain) NSString *pageTitle;
@property (nonatomic, retain) NSString *pageURL;

@end
