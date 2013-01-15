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
    GLint overlayUniform;
    GLint gradientUniform;
    GLuint gradientMapTexture;
    GLubyte *gradientMapByteArray;
}

@property(strong, nonatomic) NSArray *redCurve, *greenCurve, *blueCurve;
@property(readwrite, nonatomic) CGFloat overlay;
@property(readwrite, nonatomic) CGFloat gradient;

- (void)setRedCurve:(NSArray *)aRedCurve greenCurve:(NSArray *)aGreenCurve blueCurve:(NSArray *)aBlueCurve;

@end
