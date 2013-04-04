//
//  LXImageLens.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageLens.h"

@implementation LXImageLens {
    GLint kUniform;
    GLint kcubeUniform;
    GLint scaleUniform;
    GLint dispersionUniform;
}

- (id)init {
    self = [super initWithFragmentShaderFromFile:@"lattelens"];
    if (self) {
        runSynchronouslyOnVideoProcessingQueue(^{
            kUniform = [filterProgram uniformIndex:@"k"];
            kcubeUniform = [filterProgram uniformIndex:@"kcube"];
            scaleUniform = [filterProgram uniformIndex:@"scale"];
            dispersionUniform = [filterProgram uniformIndex:@"dispersion"];
        });
        
        [self setFloat:0.2 forUniform:kUniform program:filterProgram];
        [self setFloat:0.3 forUniform:kcubeUniform program:filterProgram];
        [self setFloat:0.8 forUniform:scaleUniform program:filterProgram];
        [self setFloat:0.01 forUniform:dispersionUniform program:filterProgram];
    }
    return self;
}

@end
