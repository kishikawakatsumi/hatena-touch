//
//  CommentCell.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/17.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell {
    UIView *cellContentView;
}

@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSString *user;

@end
