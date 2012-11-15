//
//  LXFilterMono.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/14.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterMono.h"

NSString *const kLXFilterMonoString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D gradientMapTexture;
 
 uniform lowp float overlay;
 uniform lowp float gradient;
 
 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     mediump vec4 base = texture2D(inputImageTexture, textureCoordinate);
     
     float luminance = dot(base.rgb, luminanceWeighting);
     float average = (base.r + base.g + base.b)/3.0;
     lowp vec3 greyScaleColor = vec3(luminance);
     lowp vec3 averageColor = vec3(average);

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
     
     // Vignette
     lowp float d = distance(textureCoordinate, vec2(0.5,0.5));
     base *= smoothstep(0.9, 0.45, d);
     
     // Gradient Map
     base = vec4(mix(base.rgb, texture2D(gradientMapTexture, vec2(luminance, 0.0)).rgb, gradient), base.a);
     

     
     //which is better, or are they equal?
     gl_FragColor = base;
 }
 );

@implementation LXFilterMono

@synthesize intensity;
@synthesize color;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kLXFilterMonoString]))
    {
		return nil;
    }
    
    intensityUniform = [filterProgram uniformIndex:@"intensity"];
    filterColorUniform = [filterProgram uniformIndex:@"filterColor"];
    
    self.intensity = 1.0;
	self.color = (GPUVector4){0.6f, 0.45f, 0.3f, 1.f};
	//self.color = [CIColor colorWithRed:0.6 green:0.45 blue:0.3 alpha:1.];
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setColor:(GPUVector4)aColor;
{
	
	color = aColor;
	
	[self setColorRed:color.one green:color.two blue:color.three];
}

- (void)setColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
{
    GPUVector3 filterColor = {redComponent, greenComponent, blueComponent};
    
    [self setVec3:filterColor forUniform:filterColorUniform program:filterProgram];
}

- (void)setIntensity:(CGFloat)newValue;
{
    intensity = newValue;
    
    [self setFloat:intensity forUniform:intensityUniform program:filterProgram];
}

@end
