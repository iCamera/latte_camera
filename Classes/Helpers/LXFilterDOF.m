//
//  LXFilterDOF.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2012/12/20.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterDOF.h"

@implementation LXFilterDOF

- (id)init {
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"lattedof" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];
    biasUniform = [filterProgram uniformIndex:@"bias"];
    gainUniform = [filterProgram uniformIndex:@"gain"];
    imageWidthFactorUniform = [filterProgram uniformIndex:@"imageWidthFactor"];
    imageHeightFactorUniform = [filterProgram uniformIndex:@"imageHeightFactor"];
    
    return self;
}

- (void)setBias:(CGFloat)aBias {
    [self setFloat:aBias forUniform:biasUniform program:filterProgram];
}

- (void)setGain:(CGFloat)aGain {
    [self setFloat:aGain forUniform:gainUniform program:filterProgram];
}

- (void)setupFilterForSize:(CGSize)filterFrameSize
{
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        [self setFloat:filterFrameSize.width/filterFrameSize.height forUniform:aspectratioUniform program:filterProgram];
    }
    else
    {
        [self setFloat:filterFrameSize.height/filterFrameSize.width forUniform:aspectratioUniform program:filterProgram];
    }
    
   runSynchronouslyOnVideoProcessingQueue(^{
       [GPUImageOpenGLESContext setActiveShaderProgram:filterProgram];
       
       if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
       {
           glUniform1f(imageWidthFactorUniform, 1.0 / filterFrameSize.height);
           glUniform1f(imageHeightFactorUniform, 1.0 / filterFrameSize.width);
       }
       else
       {
           glUniform1f(imageWidthFactorUniform, 1.0 / filterFrameSize.width);
           glUniform1f(imageHeightFactorUniform, 1.0 / filterFrameSize.height);
       }
   });
}

@end
