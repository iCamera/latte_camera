//
//  LXImageFilter.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/3/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "GPUImageFilter.h"

@interface LXImageFilter : GPUImageFilter

@property(readwrite, nonatomic) CGFloat vignfade;
@property(readwrite, nonatomic) CGFloat brightness;
@property(readwrite, nonatomic) CGFloat clearness;
@property(readwrite, nonatomic) CGFloat saturation;
@property(readwrite, nonatomic) CGFloat toneCurveIntensity;
@property(readwrite, nonatomic) CGFloat blendIntensity;
@property(strong, nonatomic) UIImage* toneCurve;
@property(strong, nonatomic) UIImage* imageBlend;
@property(strong, nonatomic) UIImage* imageDOF;
@property(readwrite, nonatomic) CGRect blendRegion;
@property(readwrite, nonatomic) CGFloat bias;
@property(readwrite, nonatomic) CGFloat gain;
@property(readwrite, nonatomic) BOOL dofEnable;

@property(readwrite, nonatomic) GPUImageRotationMode blendRotation;

@end
