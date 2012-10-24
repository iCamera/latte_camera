//
//  GPUImagePicture+forceProcessImage.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/22.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImagePicture+forceProcessImage.h"
#import <AVFoundation/AVFoundation.h>

@implementation GPUImagePicture (forceProcessImage)
- (void)updateOrientation:(UIDeviceOrientation) deviceOrientation cameraPosition:(NSInteger)position{
    GPUImageRotationMode outputRotation;

    if (position == AVCaptureDevicePositionBack)
    {
        switch(deviceOrientation)
        {
            case UIInterfaceOrientationPortrait:outputRotation = kGPUImageRotateRight; break;
            case UIInterfaceOrientationPortraitUpsideDown:outputRotation = kGPUImageRotateRight; break;
            case UIInterfaceOrientationLandscapeLeft:outputRotation = kGPUImageRotate180; break;
            case UIInterfaceOrientationLandscapeRight:outputRotation = kGPUImageNoRotation; break;
            case -1:outputRotation = kGPUImageNoRotation;break;
            default:
                outputRotation = kGPUImageRotateRight;
        }
    }
    else
    {
        switch(deviceOrientation)
        {
            case UIInterfaceOrientationPortrait:outputRotation = kGPUImageRotateRightFlipVertical; break;
            case UIInterfaceOrientationPortraitUpsideDown:outputRotation = kGPUImageRotateRight; break;
            case UIInterfaceOrientationLandscapeLeft:outputRotation = kGPUImageFlipHorizonal; break;
            case UIInterfaceOrientationLandscapeRight:outputRotation = kGPUImageFlipVertical; break;
            default:
                outputRotation = kGPUImageRotateRightFlipVertical;
        }
    }
    
    for (id<GPUImageInput> currentTarget in targets)
    {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        [currentTarget setInputRotation:outputRotation atIndex:[[targetTextureIndices objectAtIndex:indexOfObject] integerValue]];
    }
}
@end
