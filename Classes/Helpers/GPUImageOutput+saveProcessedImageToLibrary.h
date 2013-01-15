//
//  GPUImageFilter+saveProcessedImageToLibrary.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/05.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageFilterPipeline.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface GPUImageFilterPipeline (saveProcessedImageToLibrary)
- (void)saveImageFromCurrentlyProcessedOutputWithMeta:(NSDictionary *)metaData andOrientation:(UIImageOrientation)imageOrientation onComplete:(void(^)(NSURL *assetURL, NSError *error, UIImage *preview))block;
//- (void)saveImageByFilteringImage:(UIImage *)image withMeta:(NSDictionary *)metaData onComplete:(void(^)(NSURL *assetURL, NSError *error))block;

@end
