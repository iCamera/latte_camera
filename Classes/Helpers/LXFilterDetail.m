//
//  LXFilterDetail.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2012/12/19.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterDetail.h"

@implementation LXFilterDetail

@synthesize vignfade;
@synthesize brightness;
@synthesize clearness;
@synthesize saturation;

@synthesize redControlPoints;
@synthesize greenControlPoints;
@synthesize blueControlPoints;
@synthesize rgbCompositeControlPoints;

- (id)init;
{
    NSString *fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:@"lattefragment" ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    vignfadeUniform = [filterProgram uniformIndex:@"vignfade"];
    brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    clearnessUniform = [filterProgram uniformIndex:@"clearness"];
    saturationUniform = [filterProgram uniformIndex:@"saturation"];
    
    aspectratioUniform = [filterProgram uniformIndex:@"aspectratio"];
    
    gradientMapTextureUniform = [filterProgram uniformIndex:@"gradientMapTexture"];
    toneCurveTextureUniform = [filterProgram uniformIndex:@"gradientMapTexture"];
    
    return self;
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

- (void)setRgbCompositeControlPoints:(NSArray *)newValue
{
    rgbCompositeControlPoints = [newValue copy];
    rgbCompositeCurve = [self getPreparedSplineCurve:rgbCompositeControlPoints];
    
    [self updateToneCurveTexture];
}


- (void)setRedControlPoints:(NSArray *)newValue;
{
    redControlPoints = [newValue copy];
    redCurve = [self getPreparedSplineCurve:redControlPoints];
    
    [self updateToneCurveTexture];
}


- (void)setGreenControlPoints:(NSArray *)newValue
{
    greenControlPoints = [newValue copy];
    greenCurve = [self getPreparedSplineCurve:greenControlPoints];
    
    [self updateToneCurveTexture];
}


- (void)setBlueControlPoints:(NSArray *)newValue
{
    blueControlPoints = [newValue copy];
    blueCurve = [self getPreparedSplineCurve:blueControlPoints];
    
    [self updateToneCurveTexture];
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

- (NSArray *)getPreparedSplineCurve:(NSArray *)points
{
    if (points && [points count] > 0)
    {
        // Sort the array.
        NSArray *sortedPoints = [points sortedArrayUsingComparator:^(id a, id b) {
            float x1 = [(NSValue *)a CGPointValue].x;
            float x2 = [(NSValue *)b CGPointValue].x;
            return x1 > x2;
        }];
        
        // Convert from (0, 1) to (0, 255).
        NSMutableArray *convertedPoints = [NSMutableArray arrayWithCapacity:[sortedPoints count]];
        for (int i=0; i<[points count]; i++){
            CGPoint point = [[sortedPoints objectAtIndex:i] CGPointValue];
            point.x = point.x * 255;
            point.y = point.y * 255;
            
            [convertedPoints addObject:[NSValue valueWithCGPoint:point]];
        }
        
        
        NSMutableArray *splinePoints = [self splineCurve:convertedPoints];
        
        // If we have a first point like (0.3, 0) we'll be missing some points at the beginning
        // that should be 0.
        CGPoint firstSplinePoint = [[splinePoints objectAtIndex:0] CGPointValue];
        
        if (firstSplinePoint.x > 0) {
            for (int i=firstSplinePoint.x; i >= 0; i--) {
                CGPoint newCGPoint = CGPointMake(i, 0);
                [splinePoints insertObject:[NSValue valueWithCGPoint:newCGPoint] atIndex:0];
            }
        }
        
        // Insert points similarly at the end, if necessary.
        CGPoint lastSplinePoint = [[splinePoints objectAtIndex:([splinePoints count] - 1)] CGPointValue];
        
        if (lastSplinePoint.x < 255) {
            for (int i = lastSplinePoint.x + 1; i <= 255; i++) {
                CGPoint newCGPoint = CGPointMake(i, 255);
                [splinePoints addObject:[NSValue valueWithCGPoint:newCGPoint]];
            }
        }
        
        
        // Prepare the spline points.
        NSMutableArray *preparedSplinePoints = [NSMutableArray arrayWithCapacity:[splinePoints count]];
        for (int i=0; i<[splinePoints count]; i++)
        {
            CGPoint newPoint = [[splinePoints objectAtIndex:i] CGPointValue];
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
    
    return nil;
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
    
    // If the last point is (255, 255) it doesn't get added.
    if ([output count] == 255) {
        [output addObject:[points lastObject]];
    }
    return output;
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
        if (!toneCurveTexture)
        {
            glActiveTexture(GL_TEXTURE3);
            glGenTextures(1, &toneCurveTexture);
            glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            toneCurveByteArray = calloc(256 * 4, sizeof(GLubyte));
        }
        else
        {
            glActiveTexture(GL_TEXTURE3);
            glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
        }
        
        if ( ([redCurve count] >= 256) && ([greenCurve count] >= 256) && ([blueCurve count] >= 256) && ([rgbCompositeCurve count] >= 256))
        {
            for (unsigned int currentCurveIndex = 0; currentCurveIndex < 256; currentCurveIndex++)
            {
                // BGRA for upload to texture
                toneCurveByteArray[currentCurveIndex * 4] = fmin(fmax(currentCurveIndex + [[blueCurve objectAtIndex:currentCurveIndex] floatValue] + [[rgbCompositeCurve objectAtIndex:currentCurveIndex] floatValue], 0), 255);
                toneCurveByteArray[currentCurveIndex * 4 + 1] = fmin(fmax(currentCurveIndex + [[greenCurve objectAtIndex:currentCurveIndex] floatValue] + [[rgbCompositeCurve objectAtIndex:currentCurveIndex] floatValue], 0), 255);
                toneCurveByteArray[currentCurveIndex * 4 + 2] = fmin(fmax(currentCurveIndex + [[redCurve objectAtIndex:currentCurveIndex] floatValue] + [[rgbCompositeCurve objectAtIndex:currentCurveIndex] floatValue], 0), 255);
                toneCurveByteArray[currentCurveIndex * 4 + 3] = 255;
            }
            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256 /*width*/, 1 /*height*/, 0, GL_BGRA, GL_UNSIGNED_BYTE, toneCurveByteArray);
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
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, toneCurveTexture);
    glUniform1i(toneCurveTextureUniform, 4);
    
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
    
    if (toneCurveTexture)
    {
        glDeleteTextures(1, &toneCurveTexture);
        toneCurveTexture = 0;
        free(toneCurveByteArray);
    }
}

@end
