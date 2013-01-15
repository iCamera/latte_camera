//
//  GPUImageStillCamera+captureWithMeta.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/18.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageStillCamera.h"

@interface GPUImageStillCamera (captureWithMeta)

- (void)capturePhotoAsImageProcessedUpToFilter:(GPUImageOutput<GPUImageInput> *)finalFilterInChain
                               withOrientation:(UIImageOrientation)imageOrientation
                         withCompletionHandler:(void (^)(UIImage *processedImage, NSError *error))block;
@end
