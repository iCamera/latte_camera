//
//  LXFilterDOF.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2012/12/20.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterDOF2.h"
#import "GPUImage.h"

@implementation LXFilterDOF2 {
    GLint depthTextureUniform;
    GLint widthUniform;
    GLint heightUniform;
    GLint maxblurUniform;

    GLint gainUniform;
    GLint thresholdUniform;
    GLint ringsUniform;
    GLint samplesUniform;
    
    GLint filterSecondTextureCoordinateAttribute;
    GLint filterInputTextureUniform2;
    GPUImageRotationMode inputRotation2;
    GLuint filterSourceTexture2;
}

- (id)init {
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"latteblur" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithVertexShaderFromString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        filterSecondTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate2"];
        
        filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
        glEnableVertexAttribArray(filterSecondTextureCoordinateAttribute);
    });
    
    widthUniform = [filterProgram uniformIndex:@"width"];
    heightUniform = [filterProgram uniformIndex:@"height"];
    
    maxblurUniform = [filterProgram uniformIndex:@"maxblur"];
    
    gainUniform = [filterProgram uniformIndex:@"gain"];
    
    thresholdUniform = [filterProgram uniformIndex:@"threshold"];
    
    samplesUniform = [filterProgram uniformIndex:@"samples"];
    ringsUniform = [filterProgram uniformIndex:@"rings"];
    
    [self setInteger:4 forUniform:ringsUniform program:filterProgram];
    [self setInteger:5 forUniform:samplesUniform program:filterProgram];
    self.maxblur = 1.0;
    
    inputRotation2 = kGPUImageNoRotation;
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate2"];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    //[self setFilterFBO];
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, sourceTexture);
	glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, filterSourceTexture2);
    glUniform1i(filterInputTextureUniform2, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}



- (void)setMaxblur:(CGFloat)aMaxblur {
    _maxblur = aMaxblur;
    [self setFloat:_maxblur forUniform:maxblurUniform program:filterProgram];
}

- (void)setThreshold:(CGFloat)aThreshold {
    _threshold = aThreshold;
    [self setFloat:_threshold forUniform:thresholdUniform program:filterProgram];
}

- (void)setGain:(CGFloat)aGain {
    _gain = aGain;
    [self setFloat:_gain forUniform:gainUniform program:filterProgram];
}

- (void)setImageDOF:(UIImage *)imageDOF {
    if (!imageDOF) {
        if (filterSourceTexture2)
        {
            runSynchronouslyOnVideoProcessingQueue(^{
                [GPUImageContext useImageProcessingContext];
                glDeleteTextures(1, &filterSourceTexture2);
                filterSourceTexture2 = 0;
            });
        }
        return;
    }
    
    CGFloat widthOfImage = CGImageGetWidth(imageDOF.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(imageDOF.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), imageDOF.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        if (filterSourceTexture2)
        {
            glDeleteTextures(1, &filterSourceTexture2);
            filterSourceTexture2 = 0;
        }
        
        glActiveTexture(GL_TEXTURE3);
        glGenTextures(1, &filterSourceTexture2);
        glBindTexture(GL_TEXTURE_2D, filterSourceTexture2);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    });
    
    free(imageData);
}

- (void)setupFilterForSize:(CGSize)filterFrameSize
{
   runSynchronouslyOnVideoProcessingQueue(^{
       [GPUImageContext setActiveShaderProgram:filterProgram];
       
       if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
       {
           glUniform1f(widthUniform, filterFrameSize.height);
           glUniform1f(heightUniform, filterFrameSize.width);
       }
       else
       {
           glUniform1f(widthUniform, filterFrameSize.width);
           glUniform1f(heightUniform, filterFrameSize.height);
       }
   });
}

- (void)dealloc
{
    if (filterSourceTexture2)
    {
        glDeleteTextures(1, &filterSourceTexture2);
        filterSourceTexture2 = 0;
    }
}
@end
