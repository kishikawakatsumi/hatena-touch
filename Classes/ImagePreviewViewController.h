//
//  ImagePreviewViewController.h
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewViewController : UIViewController {
    UIImageView *imageView;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIImage *image;

@end

@protocol ImagePreviewViewControllerDelegate
- (void)imagePreviewControllerDidFinishPickingMedia:(ImagePreviewViewController *)controller;
- (void)imagePreviewControllerDidCancel:(ImagePreviewViewController *)controller;
@end