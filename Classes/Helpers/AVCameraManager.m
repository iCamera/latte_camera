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
        isCrop = false;
        
        preview = aView;
        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        crop = [[GPUImageCropFilter alloc] init];
        
//        [self toggleCrop];
        lens = [FilterManager lensNormal];
        effect = [FilterManager effect1];
        
        [effect prepareForImageCapture];

        
        [self setupCamera];
    }
    return self;
}

- (void)toggleCrop {
    isCrop = !isCrop;
    
    if (isCrop)
        [crop setCropRegion: CGRectMake(0.0f, 0.125f, 1.0f, 0.75f)];
    else
        [crop setCropRegion: CGRectMake(0.0f, 0.0, 1.0f, 1.0f)];
    
}

- (void)toggleCamera {
    [videoCamera rotateCamera];
}

- (void)startCamera {
    picture = nil;
    imageLib = nil;
    [videoCamera startCameraCapture];
}
- (void)stopCamera {
    [videoCamera stopCameraCapture];
}

- (void)pauseCamera {
    [self refreshFilter];
    [videoCamera pauseCameraCapture];
}

- (void)resumeCamera {
    picture = nil;
    imageLib = nil;
    [self refreshFilter];
    [videoCamera resumeCameraCapture];
}

- (void)setFocusPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
    if (isCrop)
        pointOfInterest = CGPointMake(point.y + 0.125, 1.0 - point.x);
    else
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
    if (isCrop)
        pointOfInterest = CGPointMake(point.y + 0.125, 1.0 - point.x);
    else
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

- (void)setupCamera {
    [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    [self refreshFilter];
}

- (void)changeLens:(GPUImageFilterGroup *)aLens {
    lens = aLens;
    [self refreshFilter];
    [pipeline replaceFilterAtIndex:1 withFilter:(id)aLens];
}

- (void)changeEffect:(GPUImageFilterGroup *)aEffect {
    effect = aEffect;
    [pipeline replaceFilterAtIndex:2 withFilter:(id)aEffect];
    [effect prepareForImageCapture];

}

- (void)refreshFilter {
    pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects:crop, lens, effect, nil] input:videoCamera output:preview];
}

- (void)processImage {
    picture = [[GPUImagePicture alloc] initWithImage:imageLib];
    
    [picture addTarget:pipeline.filters[0]];
    [picture updateOrientation:deviceOrientation cameraPosition:videoCamera.cameraPosition];
    [picture processImage];
    
    [delegate didProcessImage];
}

- (void)processUIImage:(UIImage*)image withMeta:(NSMutableDictionary*)aMeta {
    imageMeta = aMeta;
    imageLib = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(2048, 2048) interpolationQuality:kCGInterpolationHigh];
    deviceOrientation = -1;
    
    [self processImage];
}


- (void)captureNow {
    deviceOrientation = [[UIDevice currentDevice] orientation];
    [videoCamera capturePhotoAsImageWithMeta:^(UIImage *processedImage, NSMutableDictionary *metadata, NSError *error) {
        imageLib = [processedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(2048, 2048) interpolationQuality:kCGInterpolationHigh];
        imageMeta = metadata;
        
        [self processImage];
    }];
}

- (void)setDelegate:(id<AVCameraManagerDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)saveImage:(NSDictionary *)location onComplete:(void(^)(ALAsset *asset))block {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    
    [imageMeta setObject:[NSNumber numberWithInt:UIImageOrientationUp] forKey:(NSString *)kCGImagePropertyOrientation];
    // Add GPS
    if (location != nil) {
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    // Add App Info
    [imageMeta setObject:@"Latte" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    
    UIImage *imageTmp = [pipeline currentFilteredFrame];
    
    NSData *imageData = UIImageJPEGRepresentation(imageTmp, 1.0);
    [library writeImageDataToSavedPhotosAlbum:imageData metadata:imageMeta completionBlock:^(NSURL *assetURL, NSError *error) {
        [library assetForURL:assetURL
                 resultBlock:block
                failureBlock:nil];
    }];
}

@end
