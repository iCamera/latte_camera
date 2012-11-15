//
//  LXFilterMono.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/14.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageFilter.h"

@interface LXFilterMono : GPUImageFilter{
    GLint intensityUniform, filterColorUniform;
}

@property(readwrite, nonatomic) CGFloat intensity;
@property(readwrite, nonatomic) GPUVector4 color;

- (void)setColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;


@end
