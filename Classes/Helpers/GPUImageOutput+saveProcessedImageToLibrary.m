//
//  GPUImageFilter+saveProcessedImageToLibrary.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/05.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageOutput+saveProcessedImageToLibrary.h"
#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"

@implementation GPUImageFilter (saveProcessedImageToLibrary)
- (void)saveImageFromCurrentlyProcessedOutputWithMeta:(NSDictionary *)metaData andOrientation:(UIImageOrientation)imageOrientation onComplete:(void(^)(NSURL *assetURL, NSError *error, UIImage *preview))block {
    CGImageRef cgImageFromBytes = [self newCGImageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
    UIImage *finalImage = [UIImage imageWithCGImage:cgImageFromBytes scale:1.0 orientation:imageOrientation];
    CGImageRelease(cgImageFromBytes);
    UIImage *preview = [finalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(50.0, 50.0) interpolationQuality:kCGInterpolationHigh];

    preview = [preview rotateOrientation:imageOrientation];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
    [library writeImageToSavedPhotosAlbum:finalImage.CGImage metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
//        CGImageRelease(cgImageFromBytes);
        block(assetURL, error, preview);
    }];
    
//    [library writeImageToSavedPhotosAlbum:cgImageFromBytes orientation:imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
//        CGImageRelease(cgImageFromBytes);
//        block(assetURL, error);
//    }];
}

- (void)saveImageByFilteringImage:(UIImage *)image withMeta:(NSDictionary *)metaData onComplete:(void(^)(NSURL *assetURL, NSError *error))block {
    CGImageRef cgImageFromBytes = [self newCGImageByFilteringImage:image];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
    [library writeImageToSavedPhotosAlbum:cgImageFromBytes metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
        CGImageRelease(cgImageFromBytes);
        block(assetURL, error);
    }];
    
//    [library writeImageToSavedPhotosAlbum:cgImageFromBytes orientation:imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
//        CGImageRelease(cgImageFromBytes);
//        block(assetURL, error);
//    }];
}

@end
