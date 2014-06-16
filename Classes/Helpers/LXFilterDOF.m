//
//  LXFilterDOF.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2012/12/20.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterDOF.h"
#import "GPUImage.h"

@implementation LXFilterDOF {
    GLint imageWidthFactorUniform, imageHeightFactorUniform;
    GLint aspectratioUniform;
    GLint biasUniform;
    GLint gainUniform;
    
    GLint filterSecondTextureCoordinateAttribute;
    GLint filterInputTextureUniform2;
    GPUImageRotationMode inputRotation2;
    GLuint filterSourceTexture2;
}

- (id)init {
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"lattedof" ofType:@"fsh"];
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
    
    aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];
    biasUniform = [filterProgram uniformIndex:@"bias"];
    gainUniform = [filterProgram uniformIndex:@"gain"];
    imageWidthFactorUniform = [filterProgram uniformIndex:@"imageWidthFactor"];
    imageHeightFactorUniform = [filterProgram uniformIndex:@"imageHeightFactor"];
    
    inputRotation2 = kGPUImageNoRotation;
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate2"];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    GLuint currentTexture = [firstInputFramebuffer texture];
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, currentTexture);
	glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, filterSourceTexture2);
    glUniform1i(filterInputTextureUniform2, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)setBias:(CGFloat)aBias {
    [self setFloat:aBias forUniform:biasUniform program:filterProgram];
}

- (void)setGain:(CGFloat)aGain {
    [self setFloat:aGain forUniform:gainUniform program:filterProgram];
}

- (void)setImageDOF:(UIImage *)imageDOF {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        if (filterSourceTexture2)
        {
            glDeleteTextures(1, &filterSourceTexture2);
            filterSourceTexture2 = 0;
        }
        
        if (!imageDOF) {
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
        
        glActiveTexture(GL_TEXTURE3);
        glGenTextures(1, &filterSourceTexture2);
        glBindTexture(GL_TEXTURE_2D, filterSourceTexture2);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
    });
    
    
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
       [GPUImageContext setActiveShaderProgram:filterProgram];
       
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

- (void)dealloc
{
    if (filterSourceTexture2)
    {
        glDeleteTextures(1, &filterSourceTexture2);
        filterSourceTexture2 = 0;
    }
}
@end
