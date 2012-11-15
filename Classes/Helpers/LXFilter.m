//
//  LXFilter.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/12.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilter.h"

NSString *const kLXSharpenVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform float imageWidthFactor;
 uniform float imageHeightFactor;
 
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 varying vec2 topTextureCoordinate;
 varying vec2 bottomTextureCoordinate;
 
 varying float centerMultiplier;
 varying float edgeMultiplier;
 
 void main()
 {
     float sharpness = 0.5;
     gl_Position = position;
     
     mediump vec2 widthStep = vec2(imageWidthFactor, 0.0);
     mediump vec2 heightStep = vec2(0.0, imageHeightFactor);
     
     textureCoordinate = inputTextureCoordinate.xy;
     leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
     rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
     topTextureCoordinate = inputTextureCoordinate.xy + heightStep;
     bottomTextureCoordinate = inputTextureCoordinate.xy - heightStep;
     
     centerMultiplier = 1.0 + 4.0 * sharpness;
     edgeMultiplier = sharpness;
 }
 );

NSString *const kLXFragment = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 varying highp vec2 leftTextureCoordinate;
 varying highp vec2 rightTextureCoordinate;
 varying highp vec2 topTextureCoordinate;
 varying highp vec2 bottomTextureCoordinate;
 
 varying highp float centerMultiplier;
 varying highp float edgeMultiplier;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D gradientMapTexture;
 uniform lowp float saturation;
 uniform lowp float overlay;
 uniform lowp float gradient;
 uniform lowp float brightness;
 
 const highp vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     mediump vec4 base = texture2D(inputImageTexture, textureCoordinate);
     
     float luminance = dot(base.rgb, luminanceWeighting);
     float average = (base.r + base.g + base.b)/3.0;
     lowp vec3 greyScaleColor = vec3(luminance);
     lowp vec3 averageColor = vec3(average);
     
     // Sharpen
     mediump vec3 textureColor = texture2D(inputImageTexture, textureCoordinate).rgb;
     mediump vec3 leftTextureColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
     mediump vec3 rightTextureColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
     mediump vec3 topTextureColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
     mediump vec3 bottomTextureColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
     
     base = vec4((textureColor * centerMultiplier - (leftTextureColor * edgeMultiplier + rightTextureColor * edgeMultiplier + topTextureColor * edgeMultiplier + bottomTextureColor * edgeMultiplier)), texture2D(inputImageTexture, bottomTextureCoordinate).w);
     
     // Vignette
     lowp float d = distance(textureCoordinate, vec2(0.5,0.5));
     base *= smoothstep(0.9, 0.45, d);
     
     // Gradient Map
     base = vec4(mix(base.rgb, texture2D(gradientMapTexture, vec2(luminance, 0.0)).rgb, gradient), base.a);
     
     // Overlay
     
     if (base.r < 0.5) {
         base.r = 2.0 * luminance * base.r * overlay + base.r * (1.0 - overlay);
     } else {
         base.r = (1.0 - 2.0 * (1.0 - base.r) * (1.0 - luminance)) * overlay + base.r * (1.0 - overlay);
     }
     
     if (base.g < 0.5) {
         base.g = 2.0 * luminance * base.g * overlay + base.g * (1.0 - overlay);
     } else {
         base.g = (1.0 - 2.0 * (1.0 - base.g) * (1.0 - luminance)) * overlay + base.g * (1.0 - overlay);
     }
     
     if (base.b < 0.5) {
         base.b = 2.0 * luminance * base.b * overlay + base.b * (1.0 - overlay);
     } else {
         base.b = (1.0 - 2.0 * (1.0 - base.b) * (1.0 - luminance)) * overlay + base.b * (1.0 - overlay);
     }
     
     // Brightness
     vec3 brtColor = base.rgb + vec3(brightness);
     // Saturation
     vec3 satColor = mix(greyScaleColor, brtColor, 1.2);
     // Contrast
     vec3 conColor = mix(averageColor, satColor, 1.2);
     
     gl_FragColor = vec4(conColor, base.w);
 }
 );

@implementation LXFilter

@synthesize redCurve;
@synthesize greenCurve;
@synthesize blueCurve;
@synthesize overlay;
@synthesize saturation;
@synthesize gradient;
@synthesize brightness;

- (id)init;
{
    
    if (!(self = [super initWithVertexShaderFromString:kLXSharpenVertexShaderString fragmentShaderFromString:kLXFragment]))
    {
		return nil;
    }
    
    gradientMapTextureUniform = [filterProgram uniformIndex:@"gradientMapTexture"];
    saturationUniform = [filterProgram uniformIndex:@"saturation"];
    overlayUniform = [filterProgram uniformIndex:@"overlay"];
    gradientUniform = [filterProgram uniformIndex:@"gradient"];
    brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    
    imageWidthFactorUniform = [filterProgram uniformIndex:@"imageWidthFactor"];
    imageHeightFactorUniform = [filterProgram uniformIndex:@"imageHeightFactor"];
    
    saturation = 2.0;
    overlay = 0.0;
    gradient = -0.1;
    brightness = 0.0;
    
    [self setRedCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
           greenCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
            blueCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    return self;
}

- (void)setRedCurve:(NSArray *)aRedCurve greenCurve:(NSArray *)aGreenCurve blueCurve:(NSArray *)aBlueCurve {
    self.redCurve = [self splineCurve:aRedCurve];
    self.greenCurve = [self splineCurve:aGreenCurve];
    self.blueCurve = [self splineCurve:aBlueCurve];
    [self updateToneCurveTexture];
}

- (void)setSaturation:(CGFloat)aSaturation {
    saturation = aSaturation;
    [self setFloat:saturation forUniform:saturationUniform program:filterProgram];
}

- (void)setOverlay:(CGFloat)aOverlay {
    overlay = aOverlay;
    [self setFloat:overlay forUniform:overlayUniform program:filterProgram];
}

- (void)setGradient:(CGFloat)aGradient {
    gradient = aGradient;
    [self setFloat:gradient forUniform:gradientUniform program:filterProgram];
}

- (void)setBrightness:(CGFloat)aBrightness {
    brightness = aBrightness;
    [self setFloat:brightness forUniform:brightnessUniform program:filterProgram];
}

- (NSMutableArray *)splineCurve:(NSArray *)points
{
    NSMutableArray *sdA = [self secondDerivative:points];
    
    // Is [points count] equal to [sdA count]?
    //    int n = [points count];
    int n = [sdA count];
    double sd[n];
    
    // From NSMutableArray to sd[n];
    for (int i=0; i<n; i++)
    {
        sd[i] = [[sdA objectAtIndex:i] doubleValue];
    }
    
    
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:(n+1)];
    
    for(int i=0; i<n-1 ; i++)
    {
        CGPoint cur = [[points objectAtIndex:i] CGPointValue];
        CGPoint next = [[points objectAtIndex:(i+1)] CGPointValue];
        
        for(int x=cur.x;x<(int)next.x;x++)
        {
            double t = (double)(x-cur.x)/(next.x-cur.x);
            
            double a = 1-t;
            double b = t;
            double h = next.x-cur.x;
            
            double y= a*cur.y + b*next.y + (h*h/6)*( (a*a*a-a)*sd[i]+ (b*b*b-b)*sd[i+1] );
            
            if (y > 255.0)
            {
                y = 255.0;
            }
            else if (y < 0.0)
            {
                y = 0.0;
            }
            
            [output addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
    }
    
    [output addObject:points.lastObject];
    
    // Prepare the spline points.
    NSMutableArray *preparedSplinePoints = [NSMutableArray arrayWithCapacity:[output count]];
    for (int i=0; i<[output count]; i++)
    {
        CGPoint newPoint = [[output objectAtIndex:i] CGPointValue];
        CGPoint origPoint = CGPointMake(newPoint.x, newPoint.x);
        
        float distance = sqrt(pow((origPoint.x - newPoint.x), 2.0) + pow((origPoint.y - newPoint.y), 2.0));
        
        if (origPoint.y > newPoint.y)
        {
            distance = -distance;
        }
        
        [preparedSplinePoints addObject:[NSNumber numberWithFloat:distance]];
    }
    
    return preparedSplinePoints;
}

- (NSMutableArray *)secondDerivative:(NSArray *)points
{
    int n = [points count];
    if ((n <= 0) || (n == 1))
    {
        return nil;
    }
    
    double matrix[n][3];
    double result[n];
    matrix[0][1]=1;
    // What about matrix[0][1] and matrix[0][0]? Assuming 0 for now (Brad L.)
    matrix[0][0]=0;
    matrix[0][2]=0;
    
    for(int i=1;i<n-1;i++)
    {
        CGPoint P1 = [[points objectAtIndex:(i-1)] CGPointValue];
        CGPoint P2 = [[points objectAtIndex:i] CGPointValue];
        CGPoint P3 = [[points objectAtIndex:(i+1)] CGPointValue];
        
        matrix[i][0]=(double)(P2.x-P1.x)/6;
        matrix[i][1]=(double)(P3.x-P1.x)/3;
        matrix[i][2]=(double)(P3.x-P2.x)/6;
        result[i]=(double)(P3.y-P2.y)/(P3.x-P2.x) - (double)(P2.y-P1.y)/(P2.x-P1.x);
    }
    
    // What about result[0] and result[n-1]? Assuming 0 for now (Brad L.)
    result[0] = 0;
    result[n-1] = 0;
	
    matrix[n-1][1]=1;
    // What about matrix[n-1][0] and matrix[n-1][2]? For now, assuming they are 0 (Brad L.)
    matrix[n-1][0]=0;
    matrix[n-1][2]=0;
    
  	// solving pass1 (up->down)
  	for(int i=1;i<n;i++)
    {
		double k = matrix[i][0]/matrix[i-1][1];
		matrix[i][1] -= k*matrix[i-1][2];
		matrix[i][0] = 0;
		result[i] -= k*result[i-1];
    }
	// solving pass2 (down->up)
	for(int i=n-2;i>=0;i--)
    {
		double k = matrix[i][2]/matrix[i+1][1];
		matrix[i][1] -= k*matrix[i+1][0];
		matrix[i][2] = 0;
		result[i] -= k*result[i+1];
	}
    
    double y2[n];
    for(int i=0;i<n;i++) y2[i]=result[i]/matrix[i][1];
    
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:n];
    for (int i=0;i<n;i++)
    {
        [output addObject:[NSNumber numberWithDouble:y2[i]]];
    }
    
    return output;
}

- (void)updateToneCurveTexture;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        if (!gradientMapTexture)
        {
            glActiveTexture(GL_TEXTURE3);
            glGenTextures(1, &gradientMapTexture);
            glBindTexture(GL_TEXTURE_2D, gradientMapTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            gradientMapByteArray = calloc(256 * 4, sizeof(GLubyte));
        }
        else
        {
            glActiveTexture(GL_TEXTURE3);
            glBindTexture(GL_TEXTURE_2D, gradientMapTexture);
        }
        
        if ( ([redCurve count] >= 256) && ([greenCurve count] >= 256) && ([blueCurve count] >= 256))
        {
            for (unsigned int currentCurveIndex = 0; currentCurveIndex < 256; currentCurveIndex++)
            {
                // BGRA for upload to texture
                gradientMapByteArray[currentCurveIndex * 4] = currentCurveIndex + [[blueCurve objectAtIndex:currentCurveIndex] floatValue];
                gradientMapByteArray[currentCurveIndex * 4 + 1] = currentCurveIndex + [[greenCurve objectAtIndex:currentCurveIndex] floatValue];
                gradientMapByteArray[currentCurveIndex * 4 + 2] = currentCurveIndex + [[redCurve objectAtIndex:currentCurveIndex] floatValue];
                gradientMapByteArray[currentCurveIndex * 4 + 3] = 255;
            }
            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256 /*width*/, 1 /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, gradientMapByteArray);
        }
    });
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
    glBindTexture(GL_TEXTURE_2D, gradientMapTexture);
    glUniform1i(gradientMapTextureUniform, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
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

- (void)dealloc
{
    if (gradientMapTexture)
    {
        glDeleteTextures(1, &gradientMapTexture);
        gradientMapTexture = 0;
        free(gradientMapByteArray);
    }
}

@end
