//
//  HatenaSyntaxViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HatenaSyntaxViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	NSArray *hatenaSyntaxList1;
	NSArray *hatenaSyntaxList2;
	NSArray *hatenaSyntaxList3;
	NSArray *hatenaSyntaxNameList1;
	NSArray *hatenaSyntaxNameList2;
	NSArray *hatenaSyntaxNameList3;
	NSArray *hatenaSyntaxSampleList1;
	NSArray *hatenaSyntaxSampleList2;
	NSArray *hatenaSyntaxSampleList3;
    
    UITableView *listView;
}

@property (nonatomic, assign) id delegate;

@end

@protocol HatenaSyntaxViewControllerProtocol

- (void)hatenaSyntaxViewController:(HatenaSyntaxViewController *)controller didSelectSyntax:(NSString *)syntax;

@end

