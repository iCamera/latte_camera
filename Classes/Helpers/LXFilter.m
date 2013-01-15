//
//  LXFilter.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/12.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilter.h"


NSString *const kLXFragment = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D gradientMapTexture;
 
 uniform lowp float overlay;
 uniform lowp float gradient;
 
 const highp vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     mediump vec4 base = texture2D(inputImageTexture, textureCoordinate);
     
     float luminance = dot(base.rgb, luminanceWeighting);
     
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

     gl_FragColor = base;
 }
 );

@implementation LXFilter

@synthesize redCurve;
@synthesize greenCurve;
@synthesize blueCurve;
@synthesize overlay;
@synthesize gradient;

- (id)init;
{
    
    if (!(self = [super initWithFragmentShaderFromString:kLXFragment]))
    {
		return nil;
    }
    
    gradientMapTextureUniform = [filterProgram uniformIndex:@"gradientMapTexture"];

    overlayUniform = [filterProgram uniformIndex:@"overlay"];
    gradientUniform = [filterProgram uniformIndex:@"gradient"];
    overlay = 0.0;
    gradient = -0.1;

    
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


- (void)setOverlay:(CGFloat)aOverlay {
    overlay = aOverlay;
    [self setFloat:overlay forUniform:overlayUniform program:filterProgram];
}

- (void)setGradient:(CGFloat)aGradient {
    gradient = aGradient;
    [self setFloat:gradient forUniform:gradientUniform program:filterProgram];
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
