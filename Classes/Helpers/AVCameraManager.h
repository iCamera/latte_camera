//
//  AVCameraManager.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "GPUImageStillCamera+captureWithMeta.h"
#import "GPUImage.h"
#import "GPUImagePicture+forceProcessImage.h"
#import "FilterManager.h"
#import "UIImage+Resize.h"

@protocol AVCameraManagerDelegate <NSObject>
- (void)didProcessImage;
@end

@interface AVCameraManager : NSObject {
    GPUImageStillCamera *videoCamera;
    GPUImagePicture *picture;
    GPUImageView *preview;
    GPUImageFilterPipeline *pipeline;
    GPUImageFilterGroup *lens;
    GPUImageFilterGroup *effect;
    GPUImageCropFilter *crop;

    NSMutableDictionary *imageMeta;
    UIImage *imageLib;
    UIDeviceOrientation deviceOrientation;
    
    BOOL isFront;
    BOOL isCrop;
    id<AVCameraManagerDelegate> delegate;
}

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImagePicture *picture;
@property (nonatomic, strong) GPUImageFilterPipeline *pipeline;
@property (nonatomic, readonly) CGImageRef imageRef;

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

- (void)processImage;

- (void)setDelegate:(id)aDelegate;
- (void)captureNow;
- (void)processUIImage:(UIImage*)image withMeta:(NSMutableDictionary*)aMeta;
- (void)saveImage:(NSDictionary *)location onComplete:(void(^)(ALAsset *asset))block;

@end
