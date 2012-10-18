//
//  AVCameraManager.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "FilterManager.h"

@interface AVCameraManager : NSObject {
    GPUImageStillCamera *videoCamera;
    GPUImageView *preview;
    GPUImageFilterPipeline *pipeline;
    GPUImageFilterGroup *lens;
    GPUImageFilterGroup *effect;
    GPUImageCropFilter *crop;
    
    BOOL isFront;
    BOOL isCrop;
}

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilterPipeline *pipeline;

- (id)initWithView:(GPUImageView *)aView;
- (void)toggleCamera;
- (void)toggleCrop;
- (void)startCamera;
- (void)stopCamera;
- (void)pauseCamera;
- (void)resumeCamera;

- (void)setMetteringPoint:(CGPoint)point;
- (void)setFocusPoint:(CGPoint)point;
- (void)changeLens:(GPUImageFilterGroup *)aLens;
- (void)changeEffect:(GPUImageFilterGroup *)aEffect;

- (UIImage *)processImage:(UIImage *)image;

@end
