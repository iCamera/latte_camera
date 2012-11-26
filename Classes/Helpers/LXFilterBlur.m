
#import "LXFilterBlur.h"


@implementation LXFilterBlur

@synthesize focus;
@synthesize maxblur;
@synthesize focalDepth;
@synthesize autofocus;
@synthesize gain;
@synthesize threshold;

- (id)init;
{
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"blur" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    focusUniform = [filterProgram uniformIndex:@"focus"];
    
    widthUniform = [filterProgram uniformIndex:@"width"];
    heightUniform = [filterProgram uniformIndex:@"height"];
    
    maxblurUniform = [filterProgram uniformIndex:@"maxblur"];
    focalDepthUniform = [filterProgram uniformIndex:@"focalDepth"];

    autofocusUniform = [filterProgram uniformIndex:@"autofocus"];
    gainUniform = [filterProgram uniformIndex:@"gain"];

    thresholdUniform = [filterProgram uniformIndex:@"threshold"];
    
//    [self setAutofocus:true];
//    [self setFocus:CGPointMake(0.5, 0.5)];
//    [self setMaxblur:0.5];
//    [self setgain:1.25];
    
    return self;
}

- (void)setFocus:(CGPoint)aFocus {
    focus = aFocus;
    [self setPoint:focus forUniform:focusUniform program:filterProgram];
}

- (void)setMaxblur:(CGFloat)aMaxblur {
    maxblur = aMaxblur;
    [self setFloat:maxblur forUniform:maxblurUniform program:filterProgram];
}

- (void)setFocalDepth:(CGFloat)aFocalDepth {
    focalDepth = aFocalDepth;
    [self setFloat:focalDepth forUniform:focalDepthUniform program:filterProgram];
}

- (void)setAutofocus:(BOOL)aAutofocus {
    autofocus = aAutofocus;
    [self setInteger:autofocus forUniform:autofocusUniform program:filterProgram];
}
- (void)setThreshold:(CGFloat)aThreshold {
    threshold = aThreshold;
    [self setFloat:threshold forUniform:thresholdUniform program:filterProgram];
}

- (void)setGain:(CGFloat)aGain {
    gain = aGain;
    [self setFloat:gain forUniform:gainUniform program:filterProgram];
}

- (void)setFrameSize:(CGSize)frameSize {
    [self setFloat:frameSize.width forUniform:widthUniform program:filterProgram];
    [self setFloat:frameSize.height forUniform:heightUniform program:filterProgram];
}

/*
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
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    glUniform1i(depthTextureUniform, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc
{
    if (depthTexture)
    {
        glDeleteTextures(1, &depthTexture);
        depthTexture = 0;
        free(depthMapByteArray);
    }
}*/

@end
