//
//  LXFilterDetail.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2012/12/19.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageFilter.h"

@interface LXFilterDetail : GPUImageFilter {
    GLint vignfadeUniform;
    GLint brightnessUniform;
    GLint clearnessUniform;
    GLint saturationUniform;
    GLint aspectratioUniform;
    
    GLint gradientMapTextureUniform;
    GLuint gradientMapTexture;
    GLubyte *gradientMapByteArray;
    
    GLint toneCurveTextureUniform;
    GLuint toneCurveTexture;
    GLubyte *toneCurveByteArray;
    
    NSArray *rgbCompositeCurvePoints;
    NSArray *redCurvePoints;
    NSArray *greenCurvePoints;
    NSArray *blueCurvePoints;
    
    NSArray *redCurve, *greenCurve, *blueCurve, *rgbCompositeCurve;
}

@property(readwrite, nonatomic) CGFloat vignfade;
@property(readwrite, nonatomic) CGFloat brightness;
@property(readwrite, nonatomic) CGFloat clearness;
@property(readwrite, nonatomic) CGFloat saturation;

@property(readwrite, nonatomic, copy) NSArray *redControlPoints;
@property(readwrite, nonatomic, copy) NSArray *greenControlPoints;
@property(readwrite, nonatomic, copy) NSArray *blueControlPoints;
@property(readwrite, nonatomic, copy) NSArray *rgbCompositeControlPoints;

@end
