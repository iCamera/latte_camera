//
//  FilterManager.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "FilterManager.h"

@implementation FilterManager

static GPUImagePicture *texture;

+ (GPUImageFilterGroup *)lensNormal {
    GPUImageBrightnessFilter *dummy = [[GPUImageBrightnessFilter alloc] init];
    return (id)dummy;
    // GPUImageSharpenFilter *sharpen = [[GPUImageSharpenFilter alloc] init];
    // sharpen.sharpness = 0.5f;
    // return (id)sharpen;
}

+ (GPUImageFilterGroup *)lensTilt {
    GPUImageFilterGroup *lens = [[GPUImageFilterGroup alloc] init];
    GPUImagePinchDistortionFilter *distord = [[GPUImagePinchDistortionFilter alloc]init];
    GPUImageTiltShiftFilter *tilt = [[GPUImageTiltShiftFilter alloc]init];
    GPUImageSharpenFilter *sharpen = [[GPUImageSharpenFilter alloc] init];

    [distord setScale:0.1f];
    
    [sharpen addTarget: distord];
    [distord addTarget: tilt];
    
    [lens addFilter:distord];
    [lens addFilter:tilt];
    
    [lens setInitialFilters:[NSArray arrayWithObject:distord]];
    [lens setTerminalFilter:tilt];
    return lens;
}

+ (GPUImageFilterGroup *)lensFish {
    GPUImageFilterGroup *lens = [[GPUImageFilterGroup alloc] init];
    GPUImagePinchDistortionFilter *distord = [[GPUImagePinchDistortionFilter alloc]init];
    GPUImageSharpenFilter *sharpen = [[GPUImageSharpenFilter alloc] init];

    GPUImageCropFilter *crop2 = [[GPUImageCropFilter alloc] init];
    [crop2 setCropRegion: CGRectMake(0.05, 0.05, 0.9, 0.9)];
    
    [distord setScale:-0.2f];
    [distord setRadius:0.75f];
    
    [sharpen addTarget: distord];
    [distord addTarget: crop2];
    
    [lens addFilter:distord];
    [lens addFilter:crop2];
    
    [lens setInitialFilters:[NSArray arrayWithObject:distord]];
    [lens setTerminalFilter:crop2];
    return lens;
}


+ (GPUImageFilterGroup *)effect1 {
    GPUImageExposureFilter *exposure = [[GPUImageExposureFilter alloc] init];
    GPUImageVignetteFilter *vignettefilter = [[GPUImageVignetteFilter alloc] init];
    GPUImageToneCurveFilter *tonecurve = [[GPUImageToneCurveFilter alloc] init];

    exposure.exposure = 0.1;
    vignettefilter.vignetteStart = 0.55;
    vignettefilter.vignetteEnd = 0.90;
    [tonecurve setRedControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(102.0f/255.0f, 90.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(111.0f/255.0f, 108.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                    nil]];
    [tonecurve setGreenControlPoints:[NSArray arrayWithObjects:
                                      [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(83.0f/255.0f, 73.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(93.0f/255.0f, 90.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                      nil]];
    
    [tonecurve setBlueControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(86.0f/255.0f, 100.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(121.0f/255.0f, 118.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                     nil]];

    
  
    
    [exposure addTarget:vignettefilter];
    [vignettefilter addTarget:tonecurve];
    
    GPUImageFilterGroup *filter = [[GPUImageFilterGroup alloc] init];
    
    [filter addFilter:exposure];
    [filter addFilter:vignettefilter];
    [filter addFilter:tonecurve];

    
    [filter setInitialFilters:[NSArray arrayWithObject:exposure]];
    [filter setTerminalFilter:tonecurve];
    return filter;
}

+ (GPUImageFilterGroup *)effect2 {
    GPUImageExposureFilter *exposure = [[GPUImageExposureFilter alloc] init];
    GPUImageVignetteFilter *vignettefilter = [[GPUImageVignetteFilter alloc] init];
    GPUImageToneCurveFilter *tonecurve = [[GPUImageToneCurveFilter alloc] init];
    
    exposure.exposure = 0.1;
    vignettefilter.vignetteStart = 0.55;
    vignettefilter.vignetteEnd = 0.85;
    
    float curve[16][3] = {
        {23,20,60},
        {32,37,78},
        {43,54,95},
        {55,73,110},
        {68,91,124},
        {83,111,136},
        {98,130,148},
        {114,149,159},
        {130,167,168},
        {146,182,178},
        {161,198,187},
        {176,212,196},
        {191,224,204},
        {206,233,212},
        {222,241,220},
        {238,248,229}
     };
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
    
    [exposure addTarget:vignettefilter];
    [vignettefilter addTarget:tonecurve];
    
    GPUImageFilterGroup *filter = [[GPUImageFilterGroup alloc] init];
    
    [filter addFilter:exposure];
    [filter addFilter:vignettefilter];
    [filter addFilter:tonecurve];

    
    [filter setInitialFilters:[NSArray arrayWithObject:exposure]];
    [filter setTerminalFilter:tonecurve];
    
    return filter;
}

+ (GPUImageFilterGroup *)effect3 {
    GPUImageVignetteFilter *vignettefilter = [[GPUImageVignetteFilter alloc] init];
    GPUImageGrayscaleFilter *mono = [[GPUImageGrayscaleFilter alloc] init];
    GPUImageExposureFilter *exposure = [[GPUImageExposureFilter alloc] init];
    GPUImageRGBFilter *rgb = [[GPUImageRGBFilter alloc] init];
    GPUImageContrastFilter *contrast = [[GPUImageContrastFilter alloc] init];
    GPUImageBrightnessFilter *brightness = [[GPUImageBrightnessFilter alloc] init];
    GPUImageOverlayBlendFilter *blend = [[GPUImageOverlayBlendFilter alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    rgb.red = 1.36;
    rgb.green = 1.36;
    rgb.blue = 1.28;

    exposure.exposure = 0.2;
    vignettefilter.vignetteStart = 0.4;
    vignettefilter.vignetteEnd = 1.0;
    contrast.contrast = 1.1;
    brightness.brightness = -0.05;
    
    [rgb addTarget:exposure];
    [exposure addTarget:vignettefilter];
    [vignettefilter addTarget:blend];
    
    [texture processImage];
    [texture addTarget:blend];
    [blend addTarget:mono];
    
    [mono addTarget:contrast];
    [contrast addTarget:brightness];

    GPUImageFilterGroup *filter = [[GPUImageFilterGroup alloc] init];
    [filter addFilter:texture];
    [filter addFilter:rgb];
    [filter addFilter:exposure];
    [filter addFilter:vignettefilter];
    [filter addFilter:blend];
    [filter addFilter:mono];
    [filter addFilter:contrast];
    [filter addFilter:brightness];
    
    [filter setInitialFilters:[NSArray arrayWithObject:rgb]];
    [filter setTerminalFilter:brightness];
    return filter;
}


+ (GPUImageFilterGroup *)effect4 {
    GPUImageVignetteFilter *vignettefilter = [[GPUImageVignetteFilter alloc] init];
    GPUImageContrastFilter *contrast = [[GPUImageContrastFilter alloc] init];
    GPUImageBrightnessFilter *brightness = [[GPUImageBrightnessFilter alloc] init];
    GPUImageMonochromeFilter *sepia = [[GPUImageMonochromeFilter alloc] init];
    GPUImageGaussianSelectiveBlurFilter *blur = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
    
    vignettefilter.vignetteStart = 0.5;
    vignettefilter.vignetteEnd = 0.90;
    contrast.contrast = 1.85;
    brightness.brightness = 10.0/255.0;
    sepia.intensity = 0.55;
    blur.excludeCircleRadius = 220.0/320.0;
    
    [contrast addTarget:brightness];
    [brightness addTarget:blur];

    [blur addTarget:vignettefilter];
    [vignettefilter addTarget:sepia];
    
    GPUImageFilterGroup *filter = [[GPUImageFilterGroup alloc] init];
    
    [filter addFilter:contrast];
    [filter addFilter:brightness];
    [filter addFilter:blur];
    [filter addFilter:vignettefilter];
    [filter addFilter:sepia];
    
    [filter setInitialFilters:[NSArray arrayWithObject:contrast]];
    [filter setTerminalFilter:sepia];
    
    return filter;
}

+ (GPUImageFilterGroup *)effect5 {
    GPUImageVignetteFilter *vignettefilter = [[GPUImageVignetteFilter alloc] init];
    GPUImageToneCurveFilter *tonecurve = [[GPUImageToneCurveFilter alloc] init];
    GPUImageContrastFilter *contrast = [[GPUImageContrastFilter alloc] init];
    GPUImageOverlayBlendFilter *blend = [[GPUImageOverlayBlendFilter alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    vignettefilter.vignetteStart = 0.5;
    vignettefilter.vignetteEnd = 1.1;
    
    float curve[16][3] = {
        {19.0, 0.0, 0.0},
        {31.0, 9.0, 0.0},
        {41.0, 24.0, 1.0},
        {53.0, 39.0, 2.0},
        {65.0, 55.0, 25.0},
        {79.0, 72.0, 46.0},
        {93.0, 89.0, 70.0},
        {109.0, 108.0, 95.0},
        {124.0, 127.0, 122.0},
        {139.0, 146.0, 148.0},
        {154.0, 165.0, 174.0},
        {169.0, 182.0, 197.0},
        {183.0, 199.0, 219.0},
        {195.0, 215.0, 242.0},
        {207.0, 229.0, 254.0},
        {218.0, 244.0, 255.0}
    };
    contrast.contrast = 1.3;
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
    
    GPUImageFilterGroup *filter = [[GPUImageFilterGroup alloc] init];
    
    [vignettefilter addTarget:contrast];
    [contrast addTarget:blend];
    [texture addTarget:blend];
    [texture processImage];
    [blend addTarget:tonecurve];
    
    [filter addFilter:vignettefilter];
    [filter addFilter:blend];
    [filter addFilter:contrast];
    [filter addFilter:tonecurve];
    
    [filter setInitialFilters:[NSArray arrayWithObject:vignettefilter]];
    [filter setTerminalFilter:tonecurve];
    
    return filter;
}

+ (NSArray *)curveWithPoint:(float[16][3])points atIndex:(int)idx {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 16; i++) {
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(16.0*i/240.0, points[i][idx]/255.0)]];
    }
    return array;
}


@end
