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
#import "FilterManager.h"

@protocol AVCameraManagerDelegate <NSObject>
- (void)didProcessImage;
@end

@interface AVCameraManager : NSObject {
    GPUImageStillCamera *videoCamera;
    GPUImagePicture *picture;
    GPUImageView *preview;
    GPUImageFilterPipeline *pipeline;
//    GPUImageFilterGroup *lens;
//    GPUImageFilterGroup *effect;
//    GPUImageCropFilter *crop;

    NSMutableDictionary *imageMeta;
    
    BOOL isFront;
//    BOOL isCrop;
    BOOL isCapturing;

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

- (void)setMetteringPoint:(CGPoint)point;
- (void)setFocusPoint:(CGPoint)point;
//- (void)changeLens:(GPUImageFilterGroup *)aLens;
//- (void)changeEffect:(GPUImageFilterGroup *)aEffect;

- (void)processImage;

- (void)setDelegate:(id)aDelegate;
- (void)captureNow;
- (void)processUIImage:(UIImage*)image withMeta:(NSMutableDictionary*)aMeta;
- (void)saveImage:(NSDictionary *)location orientation:(UIImageOrientation)imageOrientation onComplete:(void(^)(ALAsset *asset))block;
- (void)setFlash:(BOOL)flash;
//- (void)removeAllTargets;
//- (void)refreshFilter;
- (void)initPipeWithLens:(GPUImageFilterGroup *)aLens withEffect:(GPUImageFilterGroup *)aEffect;
@end
