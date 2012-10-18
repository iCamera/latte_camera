//
//  AVCameraManager.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "AVCameraManager.h"

@implementation AVCameraManager

@synthesize videoCamera;
@synthesize pipeline;

- (id)initWithView:(GPUImageView *)aView {
    self = [super init];
    if (self) {
        isFront = false;
        isCrop = false;
        
        preview = aView;
        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        crop = [[GPUImageCropFilter alloc] init];
        [self toggleCrop];
        lens = [FilterManager lensNormal];
        effect = [FilterManager effect1];
        
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
    [videoCamera stopCameraCapture];
    isFront = !isFront;
    if (isFront) {
        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
    } else {
        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    }
    [self setupCamera];
    [videoCamera startCameraCapture];
}

- (void)startCamera {
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
}

- (void)refreshFilter {
    pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects:crop, lens, effect, nil] input:videoCamera output:preview];
}

- (UIImage *)processImage:(UIImage *)image {
    GPUImageCropFilter *dummycrop = [[GPUImageCropFilter alloc]init];
    GPUImagePicture *stillPicture = [[GPUImagePicture alloc]initWithImage:image];
    
    pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects: dummycrop, lens, effect, nil] input:stillPicture output:preview];
    [stillPicture processImage];

    return nil;
    return [pipeline currentFilteredFrame];

}



@end
