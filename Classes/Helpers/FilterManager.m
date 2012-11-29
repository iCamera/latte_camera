//
//  FilterManager.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "FilterManager.h"

@implementation FilterManager

//static GPUImagePicture *texture;

@synthesize focus;
@synthesize maxblur;
@synthesize focalDepth;
@synthesize autofocus;
@synthesize gain;
@synthesize threshold;

@synthesize frameSize;
@synthesize isDOF;
@synthesize dofOrientation;

- (id)init {
    self = [super init];
    if (self != nil) {
        brightness = [[GPUImageBrightnessFilter alloc] init];
        distord = [[GPUImagePinchDistortionFilter alloc]init];
        tiltShift = [[GPUImageTiltShiftFilter alloc]init];
        sharpen = [[GPUImageSharpenFilter alloc] init];
        vignette = [[GPUImageVignetteFilter alloc] init];
        tonecurve = [[GPUImageToneCurveFilter alloc] init];
        exposure = [[GPUImageExposureFilter alloc] init];
        rgb = [[GPUImageRGBFilter alloc] init];
        dummy = [[GPUImageBrightnessFilter alloc] init];
        crop2 = [[GPUImageCropFilter alloc] init];
        contrast = [[GPUImageContrastFilter alloc] init];
        mono = [[GPUImageGrayscaleFilter alloc] init];
        sepia = [[GPUImageMonochromeFilter alloc]init];
        blur = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
        filter = [[LXFilter alloc] init];
        lxblur = [[LXFilterBlur alloc] init];
        filterMono = [[LXFilterMono alloc] init];
        
        focus = CGPointMake(0.5, 0.5);
        maxblur = 5.0;
        threshold = 0.5;
        autofocus = false;
        focalDepth = 0.1;
        gain = 1.0;
        dofOrientation = UIImageOrientationUp;
//        grain = [[GPUImageOverlayBlendFilter alloc] init];
        
    }
    return self;
}

- (void)changeFiltertoLens:(NSInteger)aLens andEffect:(NSInteger)aEffect input:(GPUImageOutput *)aInput output:(GPUImageView *)aOutput isPicture:(BOOL)isPicture {
    [aInput removeAllTargets];
    
    [dummy setInputRotation:kGPUImageNoRotation atIndex:0];
    
    [self clearTargetWithCamera:nil andPicture:nil];
    
    switch (aLens) {
        case 0:
            [self lensNormal];
            break;
        case 1:
            [self lensTilt];
            break;
        case 2:
            [self lensFish];
            break;
    }
    
    switch (aEffect) {
        case 0:
            [self effect0];
            break;
        case 1:
            [self myEffect1];
            break;
        case 2:
            [self myEffect2];
            break;
        case 3:
            [self myEffect3];
            break;
        case 4:
            [self myEffect4];
            break;
        case 5:
            [self myEffect5];
            break;
        case 6:
            [self myEffect6];
            break;
        case 7:
            [self myEffect7];
            break;
        case 8:
            [self tmpEffect1];
            break;
        case 9:
            [self tmpEffect2];
            break;
        case 10:
            [self effect5];
            break;
        case 11:
            [self effect4];
            break;
        case 12:
            [self tmpEffect5];
            break;
        case 13:
            [self tmpEffect6];
            break;
        case 14:
            [self effect3];
            break;
        case 15:
            [self effect1];
            break;
        case 16:
            [self effect2];
            break;
    }
    
    
    if (lensIn == nil && effectIn == nil) {
        [aInput addTarget:dummy];
        if (aOutput != nil) {
            [dummy addTarget:aOutput];
        }
        lastFilter = dummy;
    } else if (lensIn == nil) {
        if (isPicture) {
            [aInput addTarget:effectIn];
            if (aOutput != nil) {
                [effectOut addTarget:aOutput];
            }
        } else {
            [aInput addTarget:dummy];
            [dummy addTarget:effectIn];
            if (aOutput != nil) {
                [effectOut addTarget:aOutput];
            }
        }
        lastFilter = effectOut;
    } else if (effectIn == nil) {
        if (isPicture) {
            [aInput addTarget:lensIn];
            if (aOutput != nil) {
                [lensOut addTarget:aOutput];
            }
        } else {
            [aInput addTarget:dummy];
            [dummy addTarget:lensIn];
            if (aOutput != nil) {
                [lensOut addTarget:aOutput];
            }
        }
        lastFilter = lensOut;
    }
    else {
        if (isPicture) {
            [aInput addTarget:effectIn];
            [effectOut addTarget:lensIn];
            if (aOutput != nil) {
                [lensOut addTarget:aOutput];
            }
        } else {
            [aInput addTarget:dummy];
            [dummy addTarget:effectIn];
            [effectOut addTarget:lensIn];
            if (aOutput != nil) {
                [lensOut addTarget:aOutput];
            }
        }
        lastFilter = lensOut;
    }
}

- (void)lensNormal {
    if ([self dofReady] && isDOF)
    {
        [self setUpRealLens];
        lensIn = lxblur;
        lensOut = lxblur;
    } else {
        lensIn = nil;
        lensOut = nil;
    }
}

- (void)setUpRealLens {
    lxblur.focus = focus;
    lxblur.autofocus = autofocus;
    lxblur.focalDepth = focalDepth;
    lxblur.maxblur = maxblur;
    lxblur.gain = gain;
    lxblur.threshold = threshold;
    lxblur.frameSize = frameSize;
    
    if (picDOF != nil) {
        [picDOF addTarget:lxblur atTextureLocation:1];
        [picDOF processImage];
        
        GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
        switch (dofOrientation) {
            case UIImageOrientationLeft:
                imageViewRotationMode = kGPUImageRotateRight;
                break;
            case UIImageOrientationRight:
                imageViewRotationMode = kGPUImageRotateLeft;
                break;
            case UIImageOrientationDown:
                imageViewRotationMode = kGPUImageRotate180;
                break;
            case UIImageOrientationUp:
                imageViewRotationMode = kGPUImageNoRotation;
                break;
            default:
                imageViewRotationMode = kGPUImageRotateLeft;
        }

        [lxblur setInputRotation:imageViewRotationMode atIndex:1];
        
    } else  {
        [lxblur disableSecondFrameCheck];
    }
}

- (void)setFocus:(CGPoint)aFocus {
    focus = aFocus;
    autofocus = true;
}

- (BOOL)dofReady {
    return picDOF != nil;
}

- (void)setDof:(UIImage *)dof {
    if (dof != nil)
        picDOF = [[GPUImagePicture alloc] initWithImage:dof];
    else
        picDOF = nil;
}

- (void)lensTilt {
    [distord setScale:0.1f];
    [distord addTarget: tiltShift];

    if ([self dofReady] && isDOF)
    {
        [self setUpRealLens];
        [lxblur addTarget: distord];
        lensIn = lxblur;
        lensOut = distord;
    } else {
        lensIn = distord;
        lensOut = distord;
    }
}

- (void)lensFish {
    [crop2 setCropRegion: CGRectMake(0.05, 0.05, 0.9, 0.9)];
    [distord setScale:-0.2f];
    [distord setRadius:0.75f];
    
    [distord addTarget: crop2];
    
    if ([self dofReady] && isDOF)
    {
        [self setUpRealLens];
        [lxblur addTarget: distord];
        lensIn = lxblur;
        lensOut = crop2;
    } else {
        lensIn = distord;
        lensOut = crop2;
    }
}

- (void)effect0 {
    effectIn = nil;
    effectOut = nil;
}


- (GPUImageFilterGroup *)effect1 {
    exposure = [[GPUImageExposureFilter alloc] init]; //hack
    
    exposure.exposure = 0.1;
    vignette.vignetteStart = 0.55;
    vignette.vignetteEnd = 0.90;
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
    
    
    
    
    [exposure addTarget:vignette];
    [vignette addTarget:tonecurve];
    
    effectIn = exposure;
    effectOut = tonecurve;
    return nil;
}

- (GPUImageFilterGroup *)effect2 {
    exposure = [[GPUImageExposureFilter alloc] init]; //hack
    
    exposure.exposure = 0.1;
    vignette.vignetteStart = 0.55;
    vignette.vignetteEnd = 0.85;
    
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
    
    [exposure addTarget:vignette];
    [vignette addTarget:tonecurve];
    
    effectIn = exposure;
    effectOut = tonecurve;
    return nil;
}

- (GPUImageFilterGroup *)effect3 {
//    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
//    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    rgb.red = 1.36;
    rgb.green = 1.36;
    rgb.blue = 1.28;
    
    exposure.exposure = 0.2;
    vignette.vignetteStart = 0.4;
    vignette.vignetteEnd = 1.0;
    contrast.contrast = 1.1;
    brightness.brightness = -0.05;
    
    [rgb addTarget:exposure];
    [exposure addTarget:mono];
//    [vignette addTarget:grain];
    
//    [texture processImage];
//    [texture addTarget:grain];
//    [grain addTarget:mono];
    
    [mono addTarget:contrast];
    [contrast addTarget:brightness];
    
    effectIn = rgb;
    effectOut = brightness;
    return nil;
}


- (GPUImageFilterGroup *)effect4 {
    vignette.vignetteStart = 0.5;
    vignette.vignetteEnd = 0.90;
    contrast.contrast = 1.85;
    brightness.brightness = 10.0/255.0;
    sepia.intensity = 0.55;
    blur.excludeCircleRadius = 220.0/320.0;
    
    [contrast addTarget:brightness];
    [brightness addTarget:blur];
    [blur addTarget:vignette];
    [vignette addTarget:sepia];
    
    effectIn = contrast;
    effectOut = sepia;
    
    return nil;
}

- (GPUImageFilterGroup *)effect5 {
//    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
//    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    vignette.vignetteStart = 0.5;
    vignette.vignetteEnd = 1.1;
    
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
    
    [vignette addTarget:contrast];
    [contrast addTarget:tonecurve];
//    [texture addTarget:grain];
//    [texture processImage];
//    [grain addTarget:tonecurve];
    
    effectIn = vignette;
    effectOut = tonecurve;
    
    return nil;
}

- (void)tmpEffect1 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"effect1"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect2 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"effect2"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect3 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"effect3"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect4 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"effect4"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect5 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"effect5"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect6 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"effect6"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (void)tmpEffect7 {
    tonecurve = [[GPUImageToneCurveFilter alloc] initWithACV:@"effect7"];
    effectIn = tonecurve;
    effectOut = tonecurve;
}

- (GPUImageFilterGroup *)curve1 {
    float curve[16][3] = {
        {12.0, 0.0, 0.0},
        {24.0, 9.0, 4.0},
        {37.0, 24.0, 10.0},
        {50.0, 40.0, 21.0},
        {64.0, 55.0, 40.0},
        {78.0, 73.0, 62.0},
        {93.0, 89.0, 83.0},
        {108.0, 107.0, 104.0},
        {125.0, 125.0, 126.0},
        {139.0, 142.0, 149.0},
        {154.0, 160.0, 170.0},
        {169.0, 177.0, 190.0},
        {183.0, 193.0, 211.0},
        {198.0, 209.0, 231.0},
        {211.0, 224.0, 244.0},
        {224.0, 240.0, 250.0}
    };
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
        
    effectIn = tonecurve;
    effectOut = tonecurve;
    
    return nil;
}

- (void)clearTargetWithCamera:(GPUImageStillCamera *)camera andPicture:(GPUImagePicture *)picture {
    if (camera != nil) {
        [camera removeAllTargets];
    }
    if (picture != nil) {
        [picture removeAllTargets];
    }
    
    [brightness removeAllTargets];
    [distord removeAllTargets];
    [tiltShift removeAllTargets];
    [sharpen removeAllTargets];
    [vignette removeAllTargets];
    [tonecurve removeAllTargets];
    [rgb removeAllTargets];
    [exposure removeAllTargets];
    [dummy removeAllTargets];
    [crop2 removeAllTargets];
    [contrast removeAllTargets];
    [mono removeAllTargets];
    [sepia removeAllTargets];
    [blur removeAllTargets];
    [filter removeAllTargets];
    [filterMono removeAllTargets];
    [picDOF removeAllTargets];
    lxblur = [[LXFilterBlur alloc] init];
//    [lxblur prepareForImageCapture];
    
//    [grain removeAllTargets];
    //    brightness = [[GPUImageBrightnessFilter alloc] init];
    //    distord = [[GPUImagePinchDistortionFilter alloc]init];
    //    tiltShift = [[GPUImageTiltShiftFilter alloc]init];
    //    sharpen = [[GPUImageSharpenFilter alloc] init];
    //    vignette = [[GPUImageVignetteFilter alloc] init];
    //    tonecurve = [[GPUImageToneCurveFilter alloc] init];
    //    exposure = [[GPUImageExposureFilter alloc] init];
    //    rgb = [[GPUImageRGBFilter alloc] init];
    //    crop = [[GPUImageCropFilter alloc] init];
    //    contrast = [[GPUImageContrastFilter alloc] init];
    //    mono = [[GPUImageGrayscaleFilter alloc] init];
    //    sepia = [[GPUImageMonochromeFilter alloc]init];
    //    blur = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
//    grain = [[GPUImageOverlayBlendFilter alloc] init];
}

- (GPUImageBrightnessFilter*) getDummy {
    return dummy;
}

- (NSArray *)curveWithPoint:(float[16][3])points atIndex:(int)idx {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 16; i++) {
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(16.0*i/240.0, points[i][idx]/255.0)]];
    }
    return array;
}


- (void)saveImage:(NSDictionary *)location orientation:(UIImageOrientation)imageOrientation withMeta:(NSMutableDictionary *)imageMeta onComplete:(void(^)(ALAsset *asset, UIImage *preview))block {
    
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    
//    [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyOrientation];
//    [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyTIFFOrientation];
    
    NSNumber *orientation = [NSNumber numberWithInteger:[self metadataOrientationForUIImageOrientation:imageOrientation]];
    
    [imageMeta setObject:orientation forKey:(NSString *)kCGImagePropertyTIFFOrientation];
    [imageMeta setObject:orientation forKey:(NSString *)kCGImagePropertyOrientation];
    
    // Add GPS
    if (location != nil) {
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    // Add App Info
    [imageMeta setObject:@"Apple" forKey:(NSString*)kCGImagePropertyTIFFMake];
    [imageMeta setObject:[[UIDevice currentDevice] model] forKey:(NSString *)kCGImagePropertyTIFFModel];
    [imageMeta setObject:@"Latte" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    
    [lastFilter saveImageFromCurrentlyProcessedOutputWithMeta:imageMeta
                                               andOrientation:imageOrientation
                                                   onComplete:^(NSURL *assetURL, NSError *error, UIImage *preview) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
                 resultBlock:^(ALAsset *asset) {
                     block(asset, preview);
                 }
                failureBlock:nil];
    }];
}

- (UIImage *)processImageWithOrientation:(UIImageOrientation)imageOrientation {
    return [lastFilter imageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
}

- (void)myEffect1 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 5)],
                       [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
           greenCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 70)],
                       [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
            blueCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 62)],
                       [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.22;
    filter.overlay = 0.58;
    filter.saturation = 2.0;
    filter.brightness = 0.0;
    
    effectIn = filter;
    effectOut = filter;
}

- (void)myEffect2 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 89)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 120)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 78)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 90)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 112)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.43;
    filter.overlay = 0.72;
    filter.saturation = 2.0;
    filter.brightness = 0.0;
    
    effectIn = filter;
    effectOut = filter;
}

- (void)myEffect3 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 73)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 184)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 69)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 186)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 51)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 142)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.48;
    filter.overlay = 0.61;
    filter.saturation = 2.0;
    filter.brightness = -0.05;
    
    effectIn = filter;
    effectOut = filter;
}

- (void)myEffect4 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 10)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 99)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 33)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 129)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 21)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 119)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.43;
    filter.overlay = 0.72;
    filter.saturation = 2.0;
    filter.brightness = 0.0;
    
    effectIn = filter;
    effectOut = filter;
}

- (void)myEffect5 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 38)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 52)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 124)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.43;
    filter.overlay = 0.72;
    filter.saturation = 2.0;
    filter.brightness = 0.0;
    
    effectIn = filter;
    effectOut = filter;
}


- (void)myEffect6 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 36)],
                         [NSValue valueWithCGPoint:CGPointMake(102, 132)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 44)],
                         [NSValue valueWithCGPoint:CGPointMake(102, 106)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 107)],
                         [NSValue valueWithCGPoint:CGPointMake(102, 106)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.95;
    filter.overlay = 0.75;
    filter.saturation = 1.5;
    filter.brightness = 0.0;
    
    effectIn = filter;
    effectOut = filter;

}


- (void)myEffect7 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 117)],
                         [NSValue valueWithCGPoint:CGPointMake(140, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 66)],
                         [NSValue valueWithCGPoint:CGPointMake(140, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 34)],
                         [NSValue valueWithCGPoint:CGPointMake(140, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.95;
    filter.overlay = 0.70;
    filter.saturation = 1.5;
    filter.brightness = 0.0;
    
    effectIn = filter;
    effectOut = filter;

}


- (int) metadataOrientationForUIImageOrientation:(UIImageOrientation)orientation
{
	switch (orientation) {
		case UIImageOrientationUp: // the picture was taken with the home button is placed right
			return 1;
		case UIImageOrientationRight: // bottom (portrait)
			return 6;
		case UIImageOrientationDown: // left
			return 3;
		case UIImageOrientationLeft: // top
			return 8;
		default:
			return 1;
	}
}

@end
