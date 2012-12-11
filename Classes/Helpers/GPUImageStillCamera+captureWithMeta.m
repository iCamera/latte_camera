//
//  GPUImageStillCamera+captureWithMeta.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/18.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageStillCamera+captureWithMeta.h"

@implementation GPUImageStillCamera (captureWithMeta)


- (void)capturePhotoAsImageProcessedUpToFilterWithMeta:(GPUImageOutput<GPUImageInput> *)finalFilterInChain
                                        forOrientation:(UIImageOrientation)imageOrientation
                                 withCompletionHandler:(void (^)(UIImage *processedImage, NSMutableDictionary *imageMeta, NSError *error))block;
{
    dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_FOREVER);
    [photoOutput captureStillImageAsynchronouslyFromConnection:[[photoOutput connections] objectAtIndex:0] completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if(imageSampleBuffer == NULL){
            dispatch_semaphore_signal(frameRenderingSemaphore);
            block(nil, nil, error);
            return;
        }
        
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, imageSampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSMutableDictionary *imageMeta = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(metadataDict)];
        CFRelease(metadataDict);
        
        // For now, resize photos to fix within the max texture size of the GPU
        CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(imageSampleBuffer);
        
        CGSize sizeOfPhoto = CGSizeMake(CVPixelBufferGetWidth(cameraFrame), CVPixelBufferGetHeight(cameraFrame));
        CGSize scaledImageSizeToFitOnGPU = [GPUImageOpenGLESContext sizeThatFitsWithinATextureForSize:sizeOfPhoto];
        // Bui, scale down for stupid device. Resize if it's not iphone 5
        CGFloat maxTextureSize;
        if ([[UIScreen mainScreen] bounds].size.height != 568) {
            maxTextureSize = 1280.0;
        } else {
            maxTextureSize = 2048.0;
        }
        
        if ( (sizeOfPhoto.width < maxTextureSize) && (sizeOfPhoto.height < maxTextureSize) )
        {
            scaledImageSizeToFitOnGPU = sizeOfPhoto;
        } else {
            CGSize adjustedSize;
            
            if (sizeOfPhoto.width > sizeOfPhoto.height)
            {
                adjustedSize.width = (CGFloat)maxTextureSize;
                adjustedSize.height = ((CGFloat)maxTextureSize / sizeOfPhoto.width) * sizeOfPhoto.height;
            }
            else
            {
                adjustedSize.height = (CGFloat)maxTextureSize;
                adjustedSize.width = ((CGFloat)maxTextureSize / sizeOfPhoto.height) * sizeOfPhoto.width;
            }
            
            scaledImageSizeToFitOnGPU = adjustedSize;
        }
        // END BUI

        if (!CGSizeEqualToSize(sizeOfPhoto, scaledImageSizeToFitOnGPU))
        {
            CMSampleBufferRef sampleBuffer;
            GPUImageCreateResizedSampleBuffer(cameraFrame, scaledImageSizeToFitOnGPU, &sampleBuffer);
            
            dispatch_semaphore_signal(frameRenderingSemaphore);
            [self captureOutput:photoOutput didOutputSampleBuffer:sampleBuffer fromConnection:[[photoOutput connections] objectAtIndex:0]];
            dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_FOREVER);
            CFRelease(sampleBuffer);
        }
        else
        {
            // This is a workaround for the corrupt images that are sometimes returned when taking a photo with the front camera and using the iOS 5.0 texture caches
            AVCaptureDevicePosition currentCameraPosition = [[videoInput device] position];
            if ( (currentCameraPosition != AVCaptureDevicePositionFront) || (![GPUImageOpenGLESContext supportsFastTextureUpload]))
            {
                dispatch_semaphore_signal(frameRenderingSemaphore);
                [self captureOutput:photoOutput didOutputSampleBuffer:imageSampleBuffer fromConnection:[[photoOutput connections] objectAtIndex:0]];
                dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_FOREVER);
            }
        }
        
        UIImage *filteredPhoto = [finalFilterInChain imageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
        dispatch_semaphore_signal(frameRenderingSemaphore);
        
        block(filteredPhoto, imageMeta, error);
    }];
    
    return;
}

@end
