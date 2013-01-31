//
//  LXEffect1.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/29.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXEffect1.h"

NSString *const kLXEffect1Fragment = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const lowp vec4 solidBlend = vec4(0.1294, 0.3647, 0.5294, 1.0);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
     lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
     lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     
     textureColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);
     lowp vec4 blendedColor = max(textureColor, solidBlend);
     
     gl_FragColor = mix(textureColor, blendedColor, 0.12);
 }
 );

@implementation LXEffect1

- (id)init;
{
    
    if (!(self = [super initWithFragmentShaderFromString:kLXEffect1Fragment]))
    {
		return nil;
    }
    
    toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
    UIImage *imageMap = [UIImage imageNamed:@"effect1curve.png"];
    [self initCurveMap:imageMap.CGImage];
    
    return self;
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
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)initCurveMap:(CGImageRef)mapSource {
    CGFloat widthOfImage = CGImageGetWidth(mapSource);
    CGFloat heightOfImage = CGImageGetHeight(mapSource);
    
    GLubyte *imageData = (GLubyte *) calloc(1, (int)widthOfImage * (int)heightOfImage * 4);
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)widthOfImage, (size_t)heightOfImage, 8, (size_t)widthOfImage * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, widthOfImage, heightOfImage), mapSource);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
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


- (void)dealloc
{
    if (toneCurveTexture)
    {
        glDeleteTextures(1, &toneCurveTexture);
        toneCurveTexture = 0;
    }
}

@end
