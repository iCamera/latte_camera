//
//  LXStillCamera.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/02/04.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "GPUImageVideoCamera.h"

@interface LXStillCamera : GPUImageVideoCamera {
    AVCaptureStillImageOutput *photoOutput;
}

@property (readonly) NSDictionary *currentCaptureMetadata;

- (void)capturePhotoAsSampleBufferWithCompletionHandler:(void (^)(CMSampleBufferRef imageSampleBuffer, NSError *error))block;

@end
