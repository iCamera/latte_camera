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
        
        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        
        [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    }
    return self;
}

- (void)toggleCrop {
}

- (void)toggleCamera {
    [videoCamera rotateCamera];
}

- (void)startCamera {
    picture = nil;
    isCapturing = true;
    [videoCamera startCameraCapture];
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


- (void)processImage {
    [picture processImage];
    [delegate didProcessImage];
}

- (void)processUIImage:(UIImage*)image withMeta:(NSMutableDictionary*)aMeta {
    picture = [[GPUImagePicture alloc] initWithImage:image];
}

- (void)setDelegate:(id<AVCameraManagerDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}
@end
