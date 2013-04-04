//
//  LXFilterFish.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/14.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterFish.h"

NSString *const kLXFisheyeFragment = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp vec2 center;
 uniform highp float radius;
 uniform highp float aspectRatio;
 uniform highp float refractiveIndex;
 // uniform vec3 lightPosition;
 const highp vec3 lightPosition = vec3(-0.5, 0.5, 1.0);
 const highp vec3 ambientLightPosition = vec3(0.0, 0.0, 2.0);
 
 void main()
 {
     highp vec2 textureCoordinateToUse = vec2(textureCoordinate.x, (textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
     highp float distanceFromCenter = distance(center, textureCoordinateToUse);
     
     distanceFromCenter = distanceFromCenter / radius;
     
     highp float normalizedDepth = radius * sqrt(1.0 - distanceFromCenter * distanceFromCenter);
     highp vec3 sphereNormal = normalize(vec3(textureCoordinateToUse - center, normalizedDepth));
     
     highp vec3 refractedVector = 2.0 * refract(vec3(0.0, 0.0, -1.0), sphereNormal, refractiveIndex);
     refractedVector.xy = -refractedVector.xy;
     
     highp vec3 finalSphereColor = texture2D(inputImageTexture, (refractedVector.xy + 1.0) * 0.5).rgb;
     
     // Grazing angle lighting
     highp float lightingIntensity = 2.5 * (1.0 - pow(clamp(dot(ambientLightPosition, sphereNormal), 0.0, 1.0), 0.25));
     finalSphereColor -= lightingIntensity;
//
     // Specular lighting
//     lightingIntensity  = clamp(dot(normalize(lightPosition), sphereNormal), 0.0, 1.0);
//     lightingIntensity  = pow(lightingIntensity, 15.0);
//     finalSphereColor -= vec3(0.8, 0.8, 0.8) * lightingIntensity;
     
     gl_FragColor = vec4(finalSphereColor, 1.0);
 }
 );

@implementation LXFilterFish


- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kLXFisheyeFragment]))
    {
		return nil;
    }
    
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    radiusUniform = [filterProgram uniformIndex:@"radius"];
    aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
    centerUniform = [filterProgram uniformIndex:@"center"];
    refractiveIndexUniform = [filterProgram uniformIndex:@"refractiveIndex"];
    
    self.radius = 0.5;
    self.center = CGPointMake(0.5, 0.5);
    self.refractiveIndex = 0.71; //default 0.71
    
    [self setBackgroundColorRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize oldInputSize = inputTextureSize;
    [super setInputSize:newSize atIndex:textureIndex];
    
    if (!CGSizeEqualToSize(oldInputSize, inputTextureSize) && (!CGSizeEqualToSize(newSize, CGSizeZero)) )
    {
        if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
        {
            [self setAspectRatio:(inputTextureSize.width / inputTextureSize.height)];
        }
        else
        {
            [self setAspectRatio:(inputTextureSize.height / inputTextureSize.width)];
        }
        CGFloat tmp = MAX(inputTextureSize.width, inputTextureSize.height) / inputTextureSize.width - 0.075;
        [self setRadius:tmp/2.0];
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setCenter:self.center];
}

- (void)setRadius:(CGFloat)newValue;
{
    _radius = newValue;
    
    [self setFloat:_radius forUniform:radiusUniform program:filterProgram];
}

- (void)setCenter:(CGPoint)newValue;
{
    _center = newValue;
    
    CGPoint rotatedPoint = [self rotatedPoint:_center forRotation:inputRotation];
    [self setPoint:rotatedPoint forUniform:centerUniform program:filterProgram];
}

- (void)setAspectRatio:(CGFloat)newValue;
{    
    [self setFloat:newValue forUniform:aspectRatioUniform program:filterProgram];
}

- (void)setRefractiveIndex:(CGFloat)newValue;
{
    _refractiveIndex = newValue;
    
    [self setFloat:_refractiveIndex forUniform:refractiveIndexUniform program:filterProgram];
}
@end
