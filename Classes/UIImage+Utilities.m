//
//  UIImage+Utilities.m
//  FoodFlow
//
//  Created by Kishikawa Katsumi on 11/09/05.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import "UIImage+Utilities.h"

@implementation UIImage(Utilities)

- (CGRect)convertCropRect:(CGRect)cropRect {
    UIImage *originalImage = self;
    
    CGSize size = originalImage.size;
    CGFloat x = cropRect.origin.x;
    CGFloat y = cropRect.origin.y;
    CGFloat width = cropRect.size.width;
    CGFloat height = cropRect.size.height;
    UIImageOrientation imageOrientation = originalImage.imageOrientation;
    if (imageOrientation == UIImageOrientationRight || imageOrientation == UIImageOrientationRightMirrored) {
        cropRect.origin.x = y;
        cropRect.origin.y = size.width - cropRect.size.width - x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationLeftMirrored) {
        cropRect.origin.x = size.height - cropRect.size.height - y;
        cropRect.origin.y = x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationDown || imageOrientation == UIImageOrientationDownMirrored) {
        cropRect.origin.x = size.width - cropRect.size.width - x;;
        cropRect.origin.y = size.height - cropRect.size.height - y;
    }
    
    return cropRect;
}

- (UIImage *)croppedImage:(CGRect)cropRect {   
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(self.CGImage ,cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1.0f orientation:self.imageOrientation];
    CGImageRelease(croppedCGImage);
    
    return croppedImage;
}

- (UIImage *)resizedImage:(CGSize)size imageOrientation:(UIImageOrientation)imageOrientation {
    CGSize imageSize = self.size;
    CGFloat horizontalRatio = size.width / imageSize.width;
    CGFloat verticalRatio = size.height / imageSize.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    CGSize targetSize = CGSizeMake(imageSize.width * ratio, imageSize.height * ratio);
    
    CGRect rect = CGRectMake(0.0f, 0.0f, targetSize.width, targetSize.height);
    
    UIGraphicsBeginImageContext(targetSize);
    [self drawInRect:rect];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

@end
