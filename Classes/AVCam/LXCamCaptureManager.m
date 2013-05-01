//
//  LXCamCaptureManager.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCamCaptureManager.h"
#import "AVCamUtilities.h"
#import <ImageIO/ImageIO.h>
#import "UIDeviceHardware.h"
#import "LXUtils.h"

@implementation LXCamCaptureManager {
//    dispatch_queue_t cameraProcessingQueue;
    BOOL needPreview;
}
- (BOOL)setupSession {
    BOOL OK = [super setupSession];
    if (OK) {
        [self.session beginConfiguration];
        
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
//        cameraProcessingQueue = dispatch_queue_create("com.luxeys.latte.cameraProcessingQueue", NULL);
        
        AVCaptureVideoDataOutput* previewOutput = [[AVCaptureVideoDataOutput alloc] init];
        [previewOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [previewOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        if ([self.session canAddOutput:previewOutput]) {
            [self.session addOutput:previewOutput];
        }
        [self.session commitConfiguration];
    }
    return OK;
}

- (UIImageOrientation)imageOrientationFromAV:(AVCaptureVideoOrientation)av {
    switch (av) {
        case AVCaptureVideoOrientationPortrait:
            return UIImageOrientationRight;
        case AVCaptureVideoOrientationLandscapeRight:
            return UIImageOrientationUp;
        case AVCaptureVideoOrientationLandscapeLeft:
            return UIImageOrientationDown;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            return UIImageOrientationLeft;
        default:
            return UIImageOrientationRight;
    }
}

- (NSInteger)exifOrientationFromAv:(AVCaptureVideoOrientation)av {
    switch (av) {
        case AVCaptureVideoOrientationLandscapeLeft:
            return 3;
        case AVCaptureVideoOrientationLandscapeRight:
            return 1;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            return 8;
        case AVCaptureVideoOrientationPortrait:
            return 6;
        default:
            return 1;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (needPreview) {
        needPreview = false;
        CGImageRef cgImage = [self imageFromSampleBuffer:sampleBuffer];
        UIImage* ret = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:[self imageOrientationFromAV:self.orientation]];
        CGImageRelease(cgImage);
        
        
        [[self delegate] lattePreviewImageCaptured:ret];
    }
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

- (void)captureStillImage{
    AVCaptureConnection *stillImageConnection = [AVCamUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    if ([stillImageConnection isVideoOrientationSupported])
        [stillImageConnection setVideoOrientation:self.orientation];
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
															 ALAssetsLibraryWriteImageCompletionBlock completionBlock = ^(NSURL *assetURL, NSError *error) {
																 if (error) {
                                                                     if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                                                         [[self delegate] captureManager:self didFailWithError:error];
                                                                     }
																 }
															 };
															 
															 if (imageDataSampleBuffer != NULL) {
																 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                 
                                                                 CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
                                                                 
                                                                 NSMutableDictionary *imageMeta = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(metadata)];

                                                                 // Create formatted date
                                                                 NSMutableDictionary *dictForEXIF = [imageMeta objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                                                                 NSMutableDictionary *dictForTIFF = [imageMeta objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
                                                                 if (dictForTIFF == nil) {
                                                                     dictForTIFF = [[NSMutableDictionary alloc] init];
                                                                 }
                                                                 if (dictForEXIF == nil) {
                                                                     dictForEXIF = [[NSMutableDictionary alloc] init];
                                                                 }
                                                                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                                 [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                                                                 NSString *stringDate = [formatter stringFromDate:[NSDate date]];
                                                                 
                                                                 // Save GPS & Correct orientation
                                                                 NSDictionary *location;
                                                                 if (_bestEffortAtLocation != nil) {
                                                                     location = [LXUtils getGPSDictionaryForLocation:_bestEffortAtLocation];
                                                                     [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
                                                                 }
                                                                 [dictForTIFF setObject:[NSNumber numberWithInteger:[self exifOrientationFromAv:self.orientation]] forKey:(NSString *)kCGImagePropertyTIFFOrientation];
                                                                 [imageMeta setObject:[NSNumber numberWithInteger:[self exifOrientationFromAv:self.orientation]] forKey:(NSString *)kCGImagePropertyOrientation];
                                                                 
                                                                 // Hardware Name
                                                                 UIDeviceHardware *hardware = [[UIDeviceHardware alloc] init];
                                                                 [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeDigitized];
                                                                 [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
                                                                 [dictForTIFF setObject:stringDate forKey:(NSString *)kCGImagePropertyTIFFDateTime];
                                                                 [dictForTIFF setObject:@"Apple" forKey:(NSString *)kCGImagePropertyTIFFMake];
                                                                 [dictForTIFF setObject:hardware.platformString forKey:(NSString *)kCGImagePropertyTIFFModel];
                                                                 
                                                                 [imageMeta setObject:dictForEXIF forKey:(NSString *)kCGImagePropertyExifDictionary];
                                                                 [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
                                                                 
                                                                 UIImage *full = [UIImage imageWithCGImage:[UIImage imageWithData:imageData].CGImage scale:1.0 orientation:[self imageOrientationFromAV:self.orientation]];
                                                                 
                                                                 [[self delegate] latteStillImageCaptured:full imageMeta:imageMeta];
                                                                 
																 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                                                 [library writeImageDataToSavedPhotosAlbum:imageData metadata:imageMeta completionBlock:completionBlock];
															 }
															 else
																 completionBlock(nil, error);
                                                             
                                                             if ([[self delegate] respondsToSelector:@selector(captureManagerStillImageCaptured:)]) {
																 [[self delegate] captureManagerStillImageCaptured:self];
															 }
                                                         }];
    needPreview = true;
}

@end
