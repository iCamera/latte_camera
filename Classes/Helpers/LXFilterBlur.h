//
//  LXFilterBlur.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/13.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageFilter.h"

@interface LXFilterBlur : GPUImageFilter {
    GLint depthTextureUniform;
    GLuint depthTexture;
    GLubyte *depthMapByteArray;
}

@end
