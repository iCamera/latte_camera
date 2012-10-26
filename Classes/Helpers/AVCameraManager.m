//
//  AVCameraManager.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "AVCameraManager.h"
#import "luxeysAppDelegate.h"

@implementation AVCameraManager

@synthesize videoCamera;
@synthesize picture;
@synthesize pipeline;
@synthesize imageRef;

- (id)initWithView:(GPUImageView *)aView {
    self = [super init];
    if (self) {
        isFront = false;
//        isCrop = false;
        
        preview = aView;
        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        
//        crop = [[GPUImageCropFilter alloc] init];
        
//        [self toggleCrop];
//        lens = [FilterManager lensNormal];
//        effect = [FilterManager effect1];
        
//        [effect prepareForImageCapture];

        [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    }
    return self;
}

- (void)toggleCrop {
//    isCrop = !isCrop;
//    
//    if (isCrop)
//        [crop setCropRegion: CGRectMake(0.0f, 0.125f, 1.0f, 0.75f)];
//    else
//        [crop setCropRegion: CGRectMake(0.0f, 0.0, 1.0f, 1.0f)];
    
}

- (void)toggleCamera {
    [videoCamera rotateCamera];
}

- (void)startCamera {
    picture = nil;
    isCapturing = true;
    [videoCamera startCameraCapture];
//    [self refreshFilter];
}
- (void)stopCamera {
    isCapturing = false;
    [videoCamera stopCameraCapture];
}

- (void)setFlash:(BOOL)flash {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFlashAvailable]) {
            if (flash)
                [device setFlashMode:AVCaptureFlashModeOn];
            else
                [device setFlashMode:AVCaptureFlashModeOff];
            [device unlockForConfiguration];
            NSLog(@"Set flash");
        }
    } else {
        NSLog(@"ERROR = %@", error);
    }
}

- (void)setFocusPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
//    if (isCrop)
//        pointOfInterest = CGPointMake(point.y + 0.125, 1.0 - point.x);
//    else
        pointOfInterest = CGPointMake(point.y, 1.0 - point.x);
    
    NSLog(@"Focus at %f %f", pointOfInterest.x, pointOfInterest.y);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
            NSLog(@"FOCUS OK");
        }
    } else {
        NSLog(@"ERROR = %@", error);
    }
}


- (void)setMetteringPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
//    if (isCrop)
//        pointOfInterest = CGPointMake(point.y + 0.125, 1.0 - point.x);
//    else
        pointOfInterest = CGPointMake(point.y, 1.0 - point.x);
    NSLog(@"Mettering at %f %f", pointOfInterest.x, pointOfInterest.y);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {;
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            NSLog(@"Mettering OK");
        }
        [device unlockForConfiguration];
        
        
    } else {
        NSLog(@"ERROR = %@", error);
    }
    
}

//- (void)changeLens:(GPUImageFilterGroup *)aLens {
//    lens = aLens;
//    [self refreshFilter];
//    [pipeline replaceFilterAtIndex:1 withFilter:(id)aLens];
//}
//
//- (void)changeEffect:(GPUImageFilterGroup *)aEffect {
//    effect = aEffect;
//    [pipeline replaceFilterAtIndex:2 withFilter:(id)aEffect];
//    [effect prepareForImageCapture];
//
//}

- (void)removeAllTargets {
    [videoCamera removeAllTargets];
    [picture removeAllTargets];
//    [crop removeAllTargets];
//    [lens removeAllTargets];
//    [effect removeAllTargets];
}
//
//- (void)refreshFilter {
//    [videoCamera removeAllTargets];
//    [picture removeAllTargets];
//    [crop removeAllTargets];
//    [lens removeAllTargets];
//    [effect removeAllTargets];
//    if (isCapturing) {
//        pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects:crop, lens, effect, nil] input:videoCamera output:preview];
//    } else {
//        pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects:crop, lens, effect, nil] input:picture output:preview];
//    }
//}

- (void)initPipeWithLens:(GPUImageFilterGroup *)aLens withEffect:(GPUImageFilterGroup *)aEffect {
    [videoCamera removeAllTargets];
    if (isCapturing) {
        pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects:aLens, aEffect, nil] input:videoCamera output:preview];
        [aEffect prepareForImageCapture];
    } else {
        pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects:aLens, aEffect, nil] input:picture output:preview];
    }
}

- (void)processImage {
//    pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects:crop, lens, effect, nil] input:picture output:preview];
    [picture processImage];
    [delegate didProcessImage];
}

- (void)processUIImage:(UIImage*)image withMeta:(NSMutableDictionary*)aMeta {
    imageMeta = aMeta;
    picture = [[GPUImagePicture alloc] initWithImage:image];
}


- (void)captureNow {
    [videoCamera capturePhotoAsImageWithMeta:^(UIImage *processedImage, NSMutableDictionary *metadata, NSError *error) {
        runOnMainQueueWithoutDeadlocking(^{
            @autoreleasepool {
                [videoCamera stopCameraCapture];
                picture = [[GPUImagePicture alloc] initWithImage:processedImage];
                imageMeta = metadata;
                [self processImage];
            }});
    }];
}

- (void)setDelegate:(id<AVCameraManagerDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)saveImage:(NSDictionary *)location orientation:(UIImageOrientation)imageOrientation onComplete:(void(^)(ALAsset *asset))block {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    
//    [imageMeta setObject:[NSNumber numberWithInt:imageOrientation] forKey:(NSString *)kCGImagePropertyOrientation];
//    [imageMeta setObject:[NSNumber numberWithInt:imageOrientation] forKey:(NSString *)kCGImagePropertyTIFFOrientation];
    [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyOrientation];
    [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyTIFFOrientation];

    // Add GPS
    if (location != nil) {
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    // Add App Info
    [imageMeta setObject:@"Latte" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    
    [picture processImage];
    GPUImageFilterGroup *effect = pipeline.filters.lastObject;
    UIImage *imageTmp = [effect imageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
    
    NSData *imageData = UIImageJPEGRepresentation(imageTmp, 0.9);
    [library writeImageDataToSavedPhotosAlbum:imageData metadata:imageMeta completionBlock:^(NSURL *assetURL, NSError *error) {
        [library assetForURL:assetURL
                 resultBlock:block
                failureBlock:nil];
    }];
}

@end
