//
//  LXEffect1.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/29.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "GPUImageFilter.h"

@interface LXEffect1 : GPUImageFilter {
    GLint toneCurveTextureUniform;
    GLuint toneCurveTexture;
}

- (void)initCurveMap:(CGImageRef)mapSource;

@end
