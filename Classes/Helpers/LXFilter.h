//
//  LXFilter.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/12.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageFilter.h"

@interface LXFilter : GPUImageFilter {
    GLint gradientMapTextureUniform;
    GLint saturationUniform;
    GLint overlayUniform;
    GLint gradientUniform;
    GLint brightnessUniform;
    GLuint gradientMapTexture;
    GLubyte *gradientMapByteArray;
    GLint imageWidthFactorUniform, imageHeightFactorUniform;
}

@property(strong, nonatomic) NSArray *redCurve, *greenCurve, *blueCurve;
@property(readwrite, nonatomic) CGFloat saturation;
@property(readwrite, nonatomic) CGFloat overlay;
@property(readwrite, nonatomic) CGFloat gradient;
@property(readwrite, nonatomic) CGFloat brightness;

- (void)setRedCurve:(NSArray *)aRedCurve greenCurve:(NSArray *)aGreenCurve blueCurve:(NSArray *)aBlueCurve;

@end
