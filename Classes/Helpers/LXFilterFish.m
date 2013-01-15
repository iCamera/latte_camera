//
//  LXFilterFish.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/14.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterFish.h"


@implementation LXFilterFish


- (id)init;
{
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"fisheye" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];

    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize {
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        [self setFloat:filterFrameSize.width/filterFrameSize.height forUniform:aspectratioUniform program:filterProgram];
    }
    else
    {
        [self setFloat:filterFrameSize.height/filterFrameSize.width forUniform:aspectratioUniform program:filterProgram];
    }
}

@end
