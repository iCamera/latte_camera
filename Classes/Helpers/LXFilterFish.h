//
//  LXFilterFish.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/14.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageFilter.h"

@interface LXFilterFish : GPUImageFilter {
    GLint radiusUniform, centerUniform, aspectRatioUniform, refractiveIndexUniform;
}

/// The center about which to apply the distortion, with a default of (0.5, 0.5)
@property(readwrite, nonatomic) CGPoint center;
/// The radius of the distortion, ranging from 0.0 to 1.0, with a default of 0.25
@property(readwrite, nonatomic) CGFloat radius;
/// The index of refraction for the sphere, with a default of 0.71
@property(readwrite, nonatomic) CGFloat refractiveIndex;

@end
