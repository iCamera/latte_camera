//
//  GPUImageFilter+saveProcessedImageToLibrary.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/05.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageOutput+saveProcessedImageToLibrary.h"

@implementation GPUImageOutput (saveProcessedImageToLibrary)
- (void)saveImageFromCurrentlyProcessedOutputWithMeta:(NSDictionary *)metaData andOrientation:(UIImageOrientation)imageOrientation onComplete:(void(^)(NSURL *assetURL, NSError *error))block {
    CGImageRef cgImageFromBytes = [self newCGImageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
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
