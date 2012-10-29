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
    
    GPUImageOverlayBlendFilter *grain;
    
    GPUImageContrastFilter *contrast;
    GPUImageGrayscaleFilter *mono;
    GPUImageMonochromeFilter *sepia;
    GPUImageGaussianSelectiveBlurFilter *blur;
    
    GPUImageOutput<GPUImageInput> *lensIn;
    GPUImageOutput<GPUImageInput> *lensOut;
    GPUImageOutput<GPUImageInput> *effectIn;
    GPUImageOutput<GPUImageInput> *effectOut;
}

- (void)changeFiltertoLens:(NSInteger)aLens andEffect:(NSInteger)aEffect input:(GPUImageOutput *)aInput output:(GPUImageView *)aOutput;
- (void)saveImage:(NSDictionary *)location orientation:(UIImageOrientation)imageOrientation withMeta:(NSMutableDictionary *)imageMeta onComplete:(void(^)(ALAsset *asset))block;
    
@end
