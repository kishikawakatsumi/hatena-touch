//
//  HatenaSyntaxCell.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/21.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HatenaSyntaxCell : UITableViewCell {
    UIView *cellContentView;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *syntax;
@property (nonatomic, retain) NSString *sample;

@end
