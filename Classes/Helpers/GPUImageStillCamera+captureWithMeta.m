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
        UIImage *image = [UIImage imageWithCGImage:[self imageFromSampleBuffer:imageSampleBuffer]];
        NSLog(@"Captured: %f x %f", image.size.width, image.size.height);

        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, imageSampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSMutableDictionary *imageMeta = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(metadataDict)];
        
        block(image, imageMeta, error);
    }];
    
    dispatch_semaphore_signal(frameRenderingSemaphore);
    
    return;
}

- (void)processMyBuffer:(CMSampleBufferRef)imageSampleBuffer {
    __unsafe_unretained GPUImageVideoCamera *weakSelf = self;
    
    if (dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
    
    dispatch_async([GPUImageOpenGLESContext sharedOpenGLESQueue], ^{
        //Feature Detection Hook.
        if (weakSelf.delegate)
        {
            [weakSelf.delegate willOutputSampleBuffer:imageSampleBuffer];
        }

        BOOL tmp = capturePaused;
        capturePaused = FALSE;
        [weakSelf processVideoSampleBuffer:imageSampleBuffer];
        capturePaused = tmp;
        
        //            CFRelease(imageSampleBuffer);
        dispatch_semaphore_signal(frameRenderingSemaphore);
    });
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
    
    CGSize pixelSizeOfImage = CGSizeMake(width, height);
    CGSize pixelSizeToUseForTexture = pixelSizeOfImage;
    
    BOOL shouldRedrawUsingCoreGraphics = NO;
    
    // For now, deal with images larger than the maximum texture size by resizing to be within that limit
    CGSize scaledImageSizeToFitOnGPU = [GPUImageOpenGLESContext sizeThatFitsWithinATextureForSize:pixelSizeOfImage];
    if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, pixelSizeOfImage))
    {
        pixelSizeOfImage = scaledImageSizeToFitOnGPU;
        pixelSizeToUseForTexture = pixelSizeOfImage;
        shouldRedrawUsingCoreGraphics = YES;
    }
    
    GLubyte *imageData = NULL;
    
    //    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
    
    if (shouldRedrawUsingCoreGraphics)
    {
        // For resized image, redraw
        imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);
        
        CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
        CGContextRef imageContext = CGBitmapContextCreate(imageData, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 8, (int)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImage);
        CGImageRef imgRef = CGBitmapContextCreateImage(imageContext);
        CGContextRelease(imageContext);
        CGColorSpaceRelease(genericRGBColorspace);
//        CVBufferRelease(imageBuffer);
        return imgRef;
    }
    else
    {
        return newImage;
    }
}

@end
