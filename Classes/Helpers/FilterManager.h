//
//  FilterManager.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "GPUImageOutput.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "GPUImageOutput+saveProcessedImageToLibrary.h"
#import "LXFilter.h"
#import "LXFilterBlur.h"
#import "LXFilterMono.h"

@interface FilterManager : NSObject {
    NSMutableArray *filters;
    /*
     0: crop
     1: lens
     2: filter
     */
    GPUImageBrightnessFilter *brightness;
    GPUImagePinchDistortionFilter *distord;
    GPUImageTiltShiftFilter *tiltShift;
    GPUImageSharpenFilter *sharpen;
    GPUImageVignetteFilter *vignette;
    GPUImageToneCurveFilter *tonecurve;
    GPUImageRGBFilter *rgb;
    GPUImageExposureFilter *exposure;
    GPUImageCropFilter *crop;
    GPUImageCropFilter *crop2;
    LXFilter *filter;
    LXFilterMono *filterMono;
    
    LXFilterBlur *lxblur;
    
//    GPUImageOverlayBlendFilter *grain;
    
    GPUImageContrastFilter *contrast;
    GPUImageGrayscaleFilter *mono;
    GPUImageMonochromeFilter *sepia;
    GPUImageGaussianSelectiveBlurFilter *blur;
    
    GPUImageFilter *lensIn;
    GPUImageFilter *lensOut;
    GPUImageFilter *effectIn;
    GPUImageFilter *effectOut;
    GPUImageFilter *lastFilter;
    
    GPUImagePicture *picDOF;

    CGFloat gain;
    CGFloat dbsize;
    CGFloat threshold;
    CGPoint focus;
    BOOL autofocus;
    CGFloat focalDepth;

    BOOL isDOF;
    CGSize frameSize;
}

@property (strong, nonatomic) UIImage* dof;
@property (readwrite, nonatomic) CGPoint focus;
@property (readwrite, nonatomic) CGFloat maxblur;
@property (readwrite, nonatomic) CGFloat threshold;
@property (readwrite, nonatomic) CGFloat gain;
@property (readwrite, nonatomic) CGFloat focalDepth;
@property (readwrite, nonatomic) BOOL autofocus;

@property (readwrite, nonatomic) BOOL isDOF;
@property (readwrite, nonatomic) CGSize frameSize;

- (void)changeFiltertoLens:(NSInteger)aLens andEffect:(NSInteger)aEffect input:(GPUImageOutput *)aInput output:(GPUImageView *)aOutput isPicture:(BOOL)isPicture;
- (void)saveImage:(NSDictionary *)location orientation:(UIImageOrientation)imageOrientation withMeta:(NSMutableDictionary *)imageMeta onComplete:(void(^)(ALAsset *asset, UIImage *preview))block;
- (void)saveUIImage:(UIImage *)picture withLocation:(NSDictionary *)location withMeta:(NSMutableDictionary *)imageMeta onComplete:(void(^)(ALAsset *asset))block;
- (GPUImageCropFilter*) getCrop;
- (void)clearTargetWithCamera:(GPUImageStillCamera *)camera andPicture:(GPUImagePicture *)picture;

@end
