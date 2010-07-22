//
//  WebViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/13.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate> {
    UIWebView *web;
    UILabel *titleView;
    UIBarButtonItem *commentButton;
    
    UIAlertView *alert;
}

@property (nonatomic, retain) NSString *pageURL;
@property (nonatomic, retain) NSDictionary *comments;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;

@end
