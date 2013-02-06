//
//  LXStillCamera.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/02/04.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXStillCamera.h"

@implementation LXStillCamera

@synthesize currentCaptureMetadata;

- (id)init;
{
    if (!(self = [self initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack]))
    {
		return nil;
    }
    return self;
}

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition;
{
    if (!(self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition]))
    {
		return nil;
    }
    
    [self.captureSession beginConfiguration];
    
    photoOutput = [[AVCaptureStillImageOutput alloc] init];
    
    [self.captureSession addOutput:photoOutput];
    
    [self.captureSession commitConfiguration];
    
    
    return self;
}

- (void)capturePhotoAsSampleBufferWithCompletionHandler:(void (^)(CMSampleBufferRef imageSampleBuffer, NSError *error))block withOrientation:(UIInterfaceOrientation)uiOrientation
{
    dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_FOREVER);
    
    AVCaptureConnection *captureConnection = [[photoOutput connections] objectAtIndex:0];
    if ([captureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        switch (uiOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                orientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                orientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                orientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                break;
        }
        
        [captureConnection setVideoOrientation:orientation];
    }
    
    [photoOutput captureStillImageAsynchronouslyFromConnection:[[photoOutput connections] objectAtIndex:0] completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL, imageSampleBuffer, kCMAttachmentMode_ShouldPropagate);
        currentCaptureMetadata = (__bridge_transfer NSDictionary *)metadata;
        block(imageSampleBuffer, error);
        currentCaptureMetadata = nil;
    }];
    
    dispatch_semaphore_signal(frameRenderingSemaphore);
    
    return;
}

- (void)removeInputsAndOutputs;
{
    [self.captureSession removeOutput:photoOutput];
    [super removeInputsAndOutputs];
}


@end
