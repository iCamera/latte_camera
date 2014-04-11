//
//  LXImageFilter.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/3/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageFilter.h"
#import "LXUtils.h"

@implementation LXImageFilter {
    GLint vignfadeUniform;
    GLint brightnessUniform;
    GLint exposureUniform;
    GLint contrastUniform;
    GLint clearnessUniform;
    GLint saturationUniform;
    GLint aspectratioUniform;
    
    GLint toneIntensityUniform;
    GLint blendIntensityUniform;
    GLint filmIntensityUniform;
    
    GLint toneEnableUniform;
    GLint blendEnableUniform;
    GLint filmEnableUniform;
    GLint textEnableUniform;
    
    GLint biasUniform;
    GLint gainUniform;
    
    GLint blendModeUniform;
    GLint filmModeUniform;
    
    GLint toneCurveTextureUniform;
    GLuint toneCurveTexture;
    
    GLint inputBlendTextureUniform;
    GLuint inputBlendTexture;
    
    GLint inputFilmTextureUniform;
    GLuint inputFilmTexture;
    
    GLint inputTextTextureUniform;
    GLuint inputTextTexture;
    
    GLfloat blendTextureCoordinates[8];
    GLfloat filmTextureCoordinates[8];
    
    GLint blendTextureCoordinateAttribute;
    GLint filmTextureCoordinateAttribute;
    GLint textTextureCoordinateAttribute;
    
    GLint sharpnessUniform;
    GLint imageWidthFactorUniform, imageHeightFactorUniform;
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
    
    uniformStateRestorationBlocks = [[NSMutableDictionary alloc] init];
    
    runSynchronouslyOnVideoProcessingQueue(^{
        vignfadeUniform = [filterProgram uniformIndex:@"vignfade"];
        brightnessUniform = [filterProgram uniformIndex:@"brightness"];
        exposureUniform = [filterProgram uniformIndex:@"exposure"];
        contrastUniform = [filterProgram uniformIndex:@"contrast"];
        clearnessUniform = [filterProgram uniformIndex:@"clearness"];
        saturationUniform = [filterProgram uniformIndex:@"saturation"];
        toneIntensityUniform = [filterProgram uniformIndex:@"toneIntensity"];
        blendIntensityUniform = [filterProgram uniformIndex:@"blendIntensity"];
        filmIntensityUniform = [filterProgram uniformIndex:@"filmIntensity"];
        
        aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];
        toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
        inputBlendTextureUniform = [filterProgram uniformIndex:@"inputBlendTexture"];
        inputFilmTextureUniform = [filterProgram uniformIndex:@"inputFilmTexture"];
        inputTextTextureUniform = [filterProgram uniformIndex:@"inputTextTexture"];
        
        toneEnableUniform = [filterProgram uniformIndex:@"toneEnable"];
        blendEnableUniform = [filterProgram uniformIndex:@"blendEnable"];
        filmEnableUniform = [filterProgram uniformIndex:@"filmEnable"];
        textEnableUniform = [filterProgram uniformIndex:@"textEnable"];
        
        biasUniform = [filterProgram uniformIndex:@"bias"];
        gainUniform = [filterProgram uniformIndex:@"gain"];
        
        filmModeUniform = [filterProgram uniformIndex:@"filmMode"];
        blendModeUniform = [filterProgram uniformIndex:@"blendMode"];
        
        blendTextureCoordinateAttribute = [filterProgram attributeIndex:@"blendTextureCoordinate"];
        filmTextureCoordinateAttribute = [filterProgram attributeIndex:@"filmTextureCoordinate"];
        textTextureCoordinateAttribute = [filterProgram attributeIndex:@"textTextureCoordinate"];
        
        glEnableVertexAttribArray(blendTextureCoordinateAttribute);
        glEnableVertexAttribArray(filmTextureCoordinateAttribute);
        glEnableVertexAttribArray(textTextureCoordinateAttribute);
        
        imageWidthFactorUniform = [filterProgram uniformIndex:@"imageWidthFactor"];
        imageHeightFactorUniform = [filterProgram uniformIndex:@"imageHeightFactor"];
        
        sharpnessUniform = [filterProgram uniformIndex:@"sharpness"];
    });
    
    self.saturation = 1.0;
    self.toneCurveIntensity = 1.0;
    self.brightness = 0.0;
    self.exposure = 0.0;
    self.contrast = 1.0;
    self.vignfade = 0.0;
    self.blendRegion = CGRectMake(0, 0, 1, 1);
    self.filmRegion = CGRectMake(0, 0, 1, 1);
    self.toneEnable = NO;
    self.blendEnable = NO;
    self.filmEnable = NO;
    self.textEnable = NO;
    self.sharpness = 0;
    self.filmMode = 4;
    self.blendMode = 4;
    
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"blendTextureCoordinate"];
    [filterProgram addAttribute:@"dofTextureCoordinate"];
    [filterProgram addAttribute:@"filmTextureCoordinate"];
    [filterProgram addAttribute:@"textTextureCoordinate"];
}

- (void)setBlendMode:(int)blendMode {
    _blendMode = blendMode;
    [self setInteger:blendMode forUniform:blendModeUniform program:filterProgram];
}

- (void)setFilmMode:(int)filmMode {
    _filmMode = filmMode;
    [self setInteger:filmMode forUniform:filmModeUniform program:filterProgram];
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

- (void)setTextEnable:(BOOL)textEnable{
    _textEnable = textEnable;
    [self setInteger:textEnable forUniform:textEnableUniform program:filterProgram];
}

- (void)setSharpness:(CGFloat)sharpness;
{
    _sharpness = sharpness;
    [self setFloat:_sharpness forUniform:sharpnessUniform program:filterProgram];
}

- (void)setExposure:(CGFloat)exposure
{
    _exposure = exposure;
    [self setFloat:_exposure forUniform:exposureUniform program:filterProgram];
}

- (void)setContrast:(CGFloat)contrast
{
    _contrast = contrast;
    [self setFloat:_contrast forUniform:contrastUniform program:filterProgram];
}

- (void)setToneCurve:(UIImage *)toneCurve {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        if (toneCurveTexture)
        {
            glDeleteTextures(1, &toneCurveTexture);
            toneCurveTexture = 0;
        }
        
        if (!toneCurve) {
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
        
        glActiveTexture(GL_TEXTURE3);
        glGenTextures(1, &toneCurveTexture);
        glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
    });
    
}

- (void)setImageBlend:(UIImage *)imageBlend {

    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        if (inputBlendTexture)
        {
            glDeleteTextures(1, &inputBlendTexture);
            inputBlendTexture = 0;
        }
        
        if (!imageBlend) {
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

        glActiveTexture(GL_TEXTURE4);
        glGenTextures(1, &inputBlendTexture);
        glBindTexture(GL_TEXTURE_2D, inputBlendTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
    });
}

- (void)setImageFilm:(UIImage *)imageFilm {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        if (inputFilmTexture)
        {
            glDeleteTextures(1, &inputFilmTexture);
            inputFilmTexture = 0;
        }
        
        if (!imageFilm) {
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
        
      
        
        glActiveTexture(GL_TEXTURE5);
        glGenTextures(1, &inputFilmTexture);
        glBindTexture(GL_TEXTURE_2D, inputFilmTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
    });
    
}

- (void)setImageText:(UIImage *)imageText {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        if (inputTextTexture)
        {
            glDeleteTextures(1, &inputTextTexture);
            inputTextTexture = 0;
        }
        
        if (!imageText) {
            return;
        }
        
        CGFloat widthOfImage = CGImageGetWidth(imageText.CGImage);
        CGFloat heightOfImage = CGImageGetHeight(imageText.CGImage);
        
        GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
        
        CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), imageText.CGImage);
        CGContextRelease(imageContext);
        CGColorSpaceRelease(genericRGBColorspace);
        
        glActiveTexture(GL_TEXTURE6);
        glGenTextures(1, &inputTextTexture);
        glBindTexture(GL_TEXTURE_2D, inputTextTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)widthOfImage /*width*/, (int)heightOfImage /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
    });
    
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
    glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
    glUniform1i(toneCurveTextureUniform, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, inputBlendTexture);
    glUniform1i(inputBlendTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, inputFilmTexture);
    glUniform1i(inputFilmTextureUniform, 5);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, inputTextTexture);
    glUniform1i(inputTextTextureUniform, 6);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(blendTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, blendTextureCoordinates);
    glVertexAttribPointer(filmTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, filmTextureCoordinates);
    glVertexAttribPointer(textTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [LXImageFilter textureCoordinatesForRotation:kGPUImageNoRotation]);
    
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

    if (inputTextTexture)
    {
        glDeleteTextures(1, &inputTextTexture);
        inputTextTexture = 0;
    }
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        [self setFloat:filterFrameSize.width/filterFrameSize.height forUniform:aspectratioUniform program:filterProgram];
        
        [self setFloat:1.0 / filterFrameSize.height forUniform:imageWidthFactorUniform program:filterProgram];
        [self setFloat:1.0 / filterFrameSize.width forUniform:imageHeightFactorUniform program:filterProgram];
    }
    else
    {
        [self setFloat:filterFrameSize.height/filterFrameSize.width forUniform:aspectratioUniform program:filterProgram];
        
        [self setFloat:1.0 / filterFrameSize.height forUniform:imageHeightFactorUniform program:filterProgram];
        [self setFloat:1.0 / filterFrameSize.width forUniform:imageWidthFactorUniform program:filterProgram];
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
        self.imageFilm = [LXUtils imageNamed:value];
    } else if ([key isEqualToString:@"blendImage"]) {
        self.imageBlend = [LXUtils imageNamed:value];
    } else if ([key isEqualToString:@"toneImage"]) {
        self.toneCurve = [LXUtils imageNamed:value];
    } else {
        NSLog(@"wtf: %@", key);
    }
}



- (void)setBackToNormal {
    //preparedToCaptureImage = NO;
}

@end
