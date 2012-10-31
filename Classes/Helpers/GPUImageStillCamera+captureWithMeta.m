//
//  GPUImageStillCamera+captureWithMeta.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/18.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageStillCamera+captureWithMeta.h"

@implementation GPUImageStillCamera (captureWithMeta)


/*- (void)capturePhotoAsImageWithMeta:(void (^)(UIImage *processedImage, NSMutableDictionary *metadata, NSError *error))block {
    
    dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_FOREVER);

    [photoOutput captureStillImageAsynchronouslyFromConnection:[[photoOutput connections] objectAtIndex:0] completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        UIImageOrientation imageOrientation = UIImageOrientationLeft;
        if ([self cameraPosition] == AVCaptureDevicePositionBack) {
            switch (deviceOrientation)
            {
                case UIDeviceOrientationPortrait:
                    imageOrientation = UIImageOrientationRight;
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    imageOrientation = UIImageOrientationRight;
                    break;
                case UIDeviceOrientationLandscapeLeft:
                    imageOrientation = UIImageOrientationUp;
                    break;
                case UIDeviceOrientationLandscapeRight:
                    imageOrientation = UIImageOrientationDown;
                    break;
                default:
                    imageOrientation = UIImageOrientationRight;
                    break;
            }
        } else
        {
            switch (deviceOrientation)
            {
                case UIDeviceOrientationPortrait:
                    imageOrientation = UIImageOrientationRight;
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    imageOrientation = UIImageOrientationRight;
                    break;
                case UIDeviceOrientationLandscapeLeft:
                    imageOrientation = UIImageOrientationDown;
                    break;
                case UIDeviceOrientationLandscapeRight:
                    imageOrientation = UIImageOrientationUp;
                    break;
                default:
                    imageOrientation = UIImageOrientationRight;
                    break;
            }
        }
        
//        CFRetain(imageSampleBuffer);
        UIImage *image = [UIImage imageWithCGImage:[self imageFromSampleBuffer:imageSampleBuffer] scale:1 orientation:imageOrientation];
//        CFRelease(imageSampleBuffer);

        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, imageSampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSMutableDictionary *imageMeta = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(metadataDict)];
        CFRelease(metadataDict);
        
        block(image, imageMeta, error);
    }];
    
    dispatch_semaphore_signal(frameRenderingSemaphore);
    
    return;
}


- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    CGSize sizeOfPhoto = CGSizeMake(CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer));
    CGSize pixelSizeToUseForTexture = sizeOfPhoto;
    CGSize scaledImageSizeToFitOnGPU = [GPUImageOpenGLESContext sizeThatFitsWithinATextureForSize:sizeOfPhoto];
    BOOL shouldRedrawUsingCoreGraphics = NO;
    if (!CGSizeEqualToSize(sizeOfPhoto, scaledImageSizeToFitOnGPU))
    {
        pixelSizeToUseForTexture = scaledImageSizeToFitOnGPU;
        CMSampleBufferRef resizedBuffer;
        GPUImageCreateResizedSampleBuffer(imageBuffer, scaledImageSizeToFitOnGPU, &resizedBuffer);
        CFRelease(resizedBuffer);
    }
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, sizeOfPhoto.width, sizeOfPhoto.height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    if (shouldRedrawUsingCoreGraphics) {
        GLubyte *imageData = (GLubyte *) calloc(1, (int)scaledImageSizeToFitOnGPU.width * (int)scaledImageSizeToFitOnGPU.height * 4);
        colorSpace = CGColorSpaceCreateDeviceRGB();
        
        newContext = CGBitmapContextCreate(imageData, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 8, (int)pixelSizeToUseForTexture.width * 4, colorSpace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGContextDrawImage(newContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImage);
        CGImageRef resizedImage = CGBitmapContextCreateImage(newContext);
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);
        free(imageData);
        
        return resizedImage;
    }
    
    return newImage;
}*/

- (void)capturePhotoAsImageProcessedUpToFilterWithMeta:(GPUImageOutput<GPUImageInput> *)finalFilterInChain withCompletionHandler:(void (^)(UIImage *processedImage, NSMutableDictionary *imageMeta, NSError *error))block;
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
        
        UIImage *filteredPhoto = [finalFilterInChain imageFromCurrentlyProcessedOutput];
        dispatch_semaphore_signal(frameRenderingSemaphore);
        
        block(filteredPhoto, imageMeta, error);
    }];
    
    return;
}

@end
