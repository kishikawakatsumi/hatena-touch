    //
//  ImagePreviewViewController.m
//  HatenaTouch
//
//  Created by Kishikawa Katsumi on 10/07/18.
//  Copyright 2010 Kishikawa Katsumi. All rights reserved.
//

#import "ImagePreviewViewController.h"

@implementation ImagePreviewViewController

@synthesize delegate;
@synthesize image;

- (void)dealloc {
    self.image = nil;
    [super dealloc];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    [contentView release];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [contentView addSubview:imageView];
    [imageView release];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 416.0f, 320.0f, 44.0f)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    toolbar.translucent = YES;
    toolbar.barStyle = UIBarStyleBlack;
    [contentView addSubview:toolbar];
    [toolbar release];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Upload", nil) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil] animated:NO];
    [flexibleSpace release];
    [doneButton release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Preview", nil);
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
    [cancelButton release];
    
    imageView.image = self.image;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark -

- (void)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imagePreviewControllerDidFinishPickingMedia:)]) {
        [self.delegate imagePreviewControllerDidFinishPickingMedia:self];
    }
}
- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imagePreviewControllerDidCancel:)]) {
        [self.delegate imagePreviewControllerDidCancel:self];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

@end
