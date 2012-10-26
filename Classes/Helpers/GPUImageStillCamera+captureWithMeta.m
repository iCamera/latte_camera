//
//  GPUImageStillCamera+captureWithMeta.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/18.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageStillCamera+captureWithMeta.h"

@implementation GPUImageStillCamera (captureWithMeta)


- (void)capturePhotoAsImageWithMeta:(void (^)(UIImage *processedImage, NSMutableDictionary *metadata, NSError *error))block {
    
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
        
        CFRetain(imageSampleBuffer);
        UIImage *image = [UIImage imageWithCGImage:[self imageFromSampleBuffer:imageSampleBuffer] scale:1 orientation:imageOrientation];
        CFRelease(imageSampleBuffer);

        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, imageSampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSMutableDictionary *imageMeta = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(metadataDict)];
        
        block(image, imageMeta, error);
    }];
    
    dispatch_semaphore_signal(frameRenderingSemaphore);
    
    return;
}


- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}

@end
