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
    GLint filmIntensityUniform;
    
    GLint toneEnableUniform;
    GLint blendEnableUniform;
    GLint filmEnableUniform;
    
    GLint biasUniform;
    GLint gainUniform;
    
    GLint toneCurveTextureUniform;
    GLuint toneCurveTexture;
    
    GLint inputBlendTextureUniform;
    GLuint inputBlendTexture;
    
    GLint inputFilmTextureUniform;
    GLuint inputFilmTexture;
    
    GLfloat blendTextureCoordinates[8];
    GLfloat filmTextureCoordinates[8];
    
    GLint blendTextureCoordinateAttribute;
    GLint filmTextureCoordinateAttribute;
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
        filmIntensityUniform = [filterProgram uniformIndex:@"filmIntensity"];
        
        aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];
        toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
        inputBlendTextureUniform = [filterProgram uniformIndex:@"inputBlendTexture"];
        inputFilmTextureUniform = [filterProgram uniformIndex:@"inputFilmTexture"];
        
        toneEnableUniform = [filterProgram uniformIndex:@"toneEnable"];
        blendEnableUniform = [filterProgram uniformIndex:@"blendEnable"];
        filmEnableUniform = [filterProgram uniformIndex:@"filmEnable"];
        
        biasUniform = [filterProgram uniformIndex:@"bias"];
        gainUniform = [filterProgram uniformIndex:@"gain"];
        
        blendTextureCoordinateAttribute = [filterProgram attributeIndex:@"blendTextureCoordinate"];
        filmTextureCoordinateAttribute = [filterProgram attributeIndex:@"filmTextureCoordinate"];
        glEnableVertexAttribArray(blendTextureCoordinateAttribute);
        glEnableVertexAttribArray(filmTextureCoordinateAttribute);
    });
    
    self.saturation = 1.0;
    self.toneCurveIntensity = 1.0;
    self.vignfade = 0;
    self.blendRegion = CGRectMake(0, 0, 1, 1);
    self.filmRegion = CGRectMake(0, 0, 1, 1);
    self.toneEnable = NO;
    self.blendEnable = NO;
    self.filmEnable = NO;
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"blendTextureCoordinate"];
    [filterProgram addAttribute:@"dofTextureCoordinate"];
    [filterProgram addAttribute:@"filmTextureCoordinate"];
}

- (void)setVignfade:(CGFloat)aVignfade
{
    _vignfade = aVignfade;
    [self setFloat:aVignfade forUniform:vignfadeUniform program:filterProgram];
}

- (void)setBrightness:(CGFloat)aBrightness
{
    _brightness = aBrightness;
    [self setFloat:aBrightness forUniform:brightnessUniform program:filterProgram];
}

- (void)setClearness:(CGFloat)aClearness {
    _clearness = aClearness;
    [self setFloat:aClearness forUniform:clearnessUniform program:filterProgram];
}

- (void)setSaturation:(CGFloat)aSaturation {
    _saturation = aSaturation;
    [self setFloat:aSaturation forUniform:saturationUniform program:filterProgram];
}

- (void)setToneCurveIntensity:(CGFloat)toneCurveIntensity {
    _toneCurveIntensity = toneCurveIntensity;
    [self setFloat:toneCurveIntensity forUniform:toneIntensityUniform program:filterProgram];
}

- (void)setBlendIntensity:(CGFloat)blendIntensity {
    _blendIntensity = blendIntensity;
    [self setFloat:blendIntensity forUniform:blendIntensityUniform program:filterProgram];
}

- (void)setFilmIntensity:(CGFloat)filmIntensity {
    _filmIntensity = filmIntensity;
    [self setFloat:filmIntensity forUniform:filmIntensityUniform program:filterProgram];
}

- (void)setToneEnable:(BOOL)toneEnable {
    _toneEnable = toneEnable;
    [self setInteger:toneEnable forUniform:toneEnableUniform program:filterProgram];
}

- (void)setBlendEnable:(BOOL)blendEnable {
    _blendEnable = blendEnable;
    [self setInteger:blendEnable forUniform:blendEnableUniform program:filterProgram];
}

- (void)setFilmEnable:(BOOL)filmEnable{
    _filmEnable = filmEnable;
    [self setInteger:filmEnable forUniform:filmEnableUniform program:filterProgram];
}

- (void)setToneCurve:(UIImage *)toneCurve {
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
    
    CGFloat widthOfImage = CGImageGetWidth(toneCurve.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(toneCurve.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), toneCurve.CGImage);
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
    
    CGFloat widthOfImage = CGImageGetWidth(imageBlend.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(imageBlend.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), imageBlend.CGImage);
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

- (void)setImageFilm:(UIImage *)imageFilm {
    if (!imageFilm) {
        if (inputFilmTexture)
        {
            runSynchronouslyOnVideoProcessingQueue(^{
                [GPUImageOpenGLESContext useImageProcessingContext];
                glDeleteTextures(1, &inputFilmTexture);
                inputFilmTexture = 0;
            });
        }
        return;
    }
    
    CGFloat widthOfImage = CGImageGetWidth(imageFilm.CGImage);
    CGFloat heightOfImage = CGImageGetHeight(imageFilm.CGImage);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), imageFilm.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        
        if (inputFilmTexture)
        {
            glDeleteTextures(1, &inputFilmTexture);
            inputFilmTexture = 0;
        }
        
        glActiveTexture(GL_TEXTURE5);
        glGenTextures(1, &inputFilmTexture);
        glBindTexture(GL_TEXTURE_2D, inputFilmTexture);
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
    glBindTexture(GL_TEXTURE_2D, inputFilmTexture);
    glUniform1i(inputFilmTextureUniform, 5);
        
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(blendTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, blendTextureCoordinates);
    glVertexAttribPointer(filmTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, filmTextureCoordinates);
    
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
        
    if (inputFilmTexture)
    {
        glDeleteTextures(1, &inputFilmTexture);
        inputFilmTexture = 0;
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

- (void)setFilmRegion:(CGRect)filmRegion {
    CGFloat minX = filmRegion.origin.x;
    CGFloat minY = filmRegion.origin.y;
    CGFloat maxX = CGRectGetMaxX(filmRegion);
    CGFloat maxY = CGRectGetMaxY(filmRegion);
    
    filmTextureCoordinates[0] = minX; // 0,0
    filmTextureCoordinates[1] = minY;
    
    filmTextureCoordinates[2] = maxX; // 1,0
    filmTextureCoordinates[3] = minY;
    
    filmTextureCoordinates[4] = minX; // 0,1
    filmTextureCoordinates[5] = maxY;
    
    filmTextureCoordinates[6] = maxX; // 1,1
    filmTextureCoordinates[7] = maxY;
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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"filmImage"]) {
        self.imageFilm = [UIImage imageNamed:value];
    } else if ([key isEqualToString:@"blendImage"]) {
        self.imageBlend = [UIImage imageNamed:value];
    } else if ([key isEqualToString:@"toneImage"]) {
        self.toneCurve = [UIImage imageNamed:value];
    } else {
        NSLog(@"wtf: %@", key);
    }
}

- (void)setBackToNormal {
    preparedToCaptureImage = NO;
}

@end
