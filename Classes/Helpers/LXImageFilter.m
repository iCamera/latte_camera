//
//  LXImageFilter.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/3/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageFilter.h"

@implementation LXImageFilter {
    GLint vignfadeUniform;
    GLint brightnessUniform;
    GLint clearnessUniform;
    GLint saturationUniform;
    GLint aspectratioUniform;
    GLint toneIntensityUniform;
    GLint blendIntensityUniform;
    GLint dofEnableUniform;
    GLint toneEnableUniform;
    GLint blendEnableUniform;
    GLint biasUniform;
    GLint gainUniform;
    
    GLint toneCurveTextureUniform;
    GLuint toneCurveTexture;
    
    GLint inputBlendTextureUniform;
    GLuint inputBlendTexture;
    
    GLint inputDOFTextureUniform;
    GLuint inputDOFTexture;
    
    GLfloat blendTextureCoordinates[8];
    
    GLint blendTextureCoordinateAttribute;
    GLint dofTextureCoordinateAttribute;
}

- (id)init;
{
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"latte" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    NSString *vertexShaderPathname = [[NSBundle mainBundle] pathForResource:@"lattevertex" ofType:@"fsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertexShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        vignfadeUniform = [filterProgram uniformIndex:@"vignfade"];
        brightnessUniform = [filterProgram uniformIndex:@"brightness"];
        clearnessUniform = [filterProgram uniformIndex:@"clearness"];
        saturationUniform = [filterProgram uniformIndex:@"saturation"];
        toneIntensityUniform = [filterProgram uniformIndex:@"toneIntensity"];
        blendIntensityUniform = [filterProgram uniformIndex:@"blendIntensity"];
        aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];
        toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
        inputBlendTextureUniform = [filterProgram uniformIndex:@"inputBlendTexture"];
        inputDOFTextureUniform = [filterProgram uniformIndex:@"inputDOFTexture"];
        
        toneEnableUniform = [filterProgram uniformIndex:@"toneEnable"];
        blendEnableUniform = [filterProgram uniformIndex:@"blendEnable"];
        
        dofEnableUniform = [filterProgram uniformIndex:@"dofEnable"];
        biasUniform = [filterProgram uniformIndex:@"bias"];
        gainUniform = [filterProgram uniformIndex:@"gain"];
        
        blendTextureCoordinateAttribute = [filterProgram attributeIndex:@"blendTextureCoordinate"];
        dofTextureCoordinateAttribute = [filterProgram attributeIndex:@"dofTextureCoordinate"];
        glEnableVertexAttribArray(blendTextureCoordinateAttribute);
        glEnableVertexAttribArray(dofTextureCoordinateAttribute);
    });
    
    self.saturation = 1.0;
    self.toneCurveIntensity = 1.0;
    self.vignfade = 1.0;
    self.blendRegion = CGRectMake(0, 0, 1, 1);
    [self setToneEnable:false];
    self.dofEnable = NO;
    self.blendEnable = NO;
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"blendTextureCoordinate"];
    [filterProgram addAttribute:@"dofTextureCoordinate"];
}

- (void)setVignfade:(CGFloat)aVignfade
{
    [self setFloat:aVignfade forUniform:vignfadeUniform program:filterProgram];
}

- (void)setBrightness:(CGFloat)aBrightness
{
    [self setFloat:aBrightness forUniform:brightnessUniform program:filterProgram];
}

- (void)setClearness:(CGFloat)aClearness {
    [self setFloat:aClearness forUniform:clearnessUniform program:filterProgram];
}

- (void)setSaturation:(CGFloat)aSaturation {
    [self setFloat:aSaturation forUniform:saturationUniform program:filterProgram];
}

- (void)setToneCurveIntensity:(CGFloat)toneCurveIntensity {
    [self setFloat:toneCurveIntensity forUniform:toneIntensityUniform program:filterProgram];
}

- (void)setBlendIntensity:(CGFloat)blendIntensity {
    [self setFloat:blendIntensity forUniform:blendIntensityUniform program:filterProgram];
}

- (void)setBias:(CGFloat)aBias {
    [self setFloat:aBias forUniform:biasUniform program:filterProgram];
}

- (void)setGain:(CGFloat)aGain {
    [self setFloat:aGain forUniform:gainUniform program:filterProgram];
}

- (void)setToneEnable:(BOOL)toneEnable {
    [self setInteger:toneEnable forUniform:toneEnableUniform program:filterProgram];
}

- (void)setBlendEnable:(BOOL)blendEnable {
    [self setInteger:blendEnable forUniform:blendEnableUniform program:filterProgram];
}

- (void)setDofEnable:(BOOL)dofEnable {
    [self setInteger:dofEnable forUniform:dofEnableUniform program:filterProgram];
}

- (void)setToneCurve:(UIImage *)toneCurve {
    _toneCurve = toneCurve;
    if (!toneCurve) {
        if (toneCurveTexture)
        {
            runSynchronouslyOnVideoProcessingQueue(^{
                [GPUImageOpenGLESContext useImageProcessingContext];
                glDeleteTextures(1, &toneCurveTexture);
                toneCurveTexture = 0;
            });
        }
        return;
    }
    
    CGFloat widthOfImage = CGImageGetWidth(_toneCurve.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(_toneCurve.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), _toneCurve.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        
        if (toneCurveTexture)
        {
            glDeleteTextures(1, &toneCurveTexture);
            toneCurveTexture = 0;
        }
        
        glActiveTexture(GL_TEXTURE3);
        glGenTextures(1, &toneCurveTexture);
        glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    });
    
    free(imageData);
}

- (void)setImageBlend:(UIImage *)imageBlend {
    _imageBlend = imageBlend;
    if (!imageBlend) {
        if (inputBlendTexture)
        {
            runSynchronouslyOnVideoProcessingQueue(^{
                [GPUImageOpenGLESContext useImageProcessingContext];
                glDeleteTextures(1, &inputBlendTexture);
                inputBlendTexture = 0;
            });
        }
        return;
    }
    
    CGFloat widthOfImage = CGImageGetWidth(_imageBlend.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(_imageBlend.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), _imageBlend.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        
        if (inputBlendTexture)
        {
            glDeleteTextures(1, &inputBlendTexture);
            inputBlendTexture = 0;
        }

        glActiveTexture(GL_TEXTURE4);
        glGenTextures(1, &inputBlendTexture);
        glBindTexture(GL_TEXTURE_2D, inputBlendTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    });
    
    free(imageData);
}

- (void)setImageDOF:(UIImage *)imageDOF {
    _imageDOF = imageDOF;
    if (!imageDOF) {
        if (inputDOFTexture)
        {
            runSynchronouslyOnVideoProcessingQueue(^{
                [GPUImageOpenGLESContext useImageProcessingContext];
                glDeleteTextures(1, &inputDOFTexture);
                inputDOFTexture = 0;
            });
        }
        return;
    }
    
    CGFloat widthOfImage = CGImageGetWidth(_imageDOF.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(_imageDOF.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), _imageDOF.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        
        if (inputDOFTexture)
        {
            glDeleteTextures(1, &inputDOFTexture);
            inputDOFTexture = 0;
        }
        
        glActiveTexture(GL_TEXTURE5);
        glGenTextures(1, &inputDOFTexture);
        glBindTexture(GL_TEXTURE_2D, inputDOFTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    });
    
    free(imageData);
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [GPUImageOpenGLESContext setActiveShaderProgram:filterProgram];
    [self setFilterFBO];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
  	glActiveTexture(GL_TEXTURE2);
  	glBindTexture(GL_TEXTURE_2D, sourceTexture);
  	glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
    glUniform1i(toneCurveTextureUniform, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, inputBlendTexture);
    glUniform1i(inputBlendTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, inputDOFTexture);
    glUniform1i(inputDOFTextureUniform, 5);
    
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(dofTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, noRotationTextureCoordinates);
    glVertexAttribPointer(blendTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, blendTextureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)dealloc
{
    if (inputBlendTexture)
    {
        glDeleteTextures(1, &inputBlendTexture);
        inputBlendTexture = 0;
    }
    
    if (toneCurveTexture)
    {
        glDeleteTextures(1, &toneCurveTexture);
        toneCurveTexture = 0;
    }
    
    if (inputDOFTexture)
    {
        glDeleteTextures(1, &inputDOFTexture);
        inputDOFTexture = 0;
    }

}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        [self setFloat:filterFrameSize.width/filterFrameSize.height forUniform:aspectratioUniform program:filterProgram];
    }
    else
    {
        [self setFloat:filterFrameSize.height/filterFrameSize.width forUniform:aspectratioUniform program:filterProgram];
    }
}


- (void)setBlendRegion:(CGRect)blendRegion {
    _blendRegion = blendRegion;
    [self calculateCropTextureCoordinates];
}


- (void)calculateCropTextureCoordinates;
{
    CGFloat minX = _blendRegion.origin.x;
    CGFloat minY = _blendRegion.origin.y;
    CGFloat maxX = CGRectGetMaxX(_blendRegion);
    CGFloat maxY = CGRectGetMaxY(_blendRegion);
    
    blendTextureCoordinates[0] = minX; // 0,0
    blendTextureCoordinates[1] = minY;
    
    blendTextureCoordinates[2] = maxX; // 1,0
    blendTextureCoordinates[3] = minY;
    
    blendTextureCoordinates[4] = minX; // 0,1
    blendTextureCoordinates[5] = maxY;
    
    blendTextureCoordinates[6] = maxX; // 1,1
    blendTextureCoordinates[7] = maxY;
}


@end
