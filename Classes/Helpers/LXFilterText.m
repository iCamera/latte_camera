//
//  LXFilterText.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/16.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXFilterText.h"


NSString *const kLXFilterTextFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp vec2 aspect;
 uniform lowp float scale;
 uniform lowp vec2 position;
 
 void main()
 {
     lowp vec4 c2 = texture2D(inputImageTexture, textureCoordinate);
	 lowp vec4 c1 = texture2D(inputImageTexture2, (textureCoordinate2*aspect-(position*aspect))/scale);
     
     lowp vec4 outputColor;
     
     outputColor.r = c1.r + c2.r * c2.a * (1.0 - c1.a);
     
     outputColor.g = c1.g + c2.g * c2.a * (1.0 - c1.a);
     
     outputColor.b = c1.b + c2.b * c2.a * (1.0 - c1.a);
     
     outputColor.a = c1.a + c2.a * (1.0 - c1.a);
     
     gl_FragColor = outputColor;
 }
 );

@implementation LXFilterText

@synthesize position;
@synthesize aspect;
@synthesize scale;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kLXFilterTextFragmentShaderString]))
    {
		return nil;
    }
    
    aspectUniform = [filterProgram uniformIndex:@"aspect"];
    positionUniform = [filterProgram uniformIndex:@"position"];
    scaleUniform = [filterProgram uniformIndex:@"scale"];
    
    self.position = CGPointMake(0.1, 0.5);
    self.aspect = CGPointMake(1.0, 1.0);
    self.scale = 0.3;
        
    return self;
}

- (void)setPosition:(CGPoint)aPosition {
    [self setPoint:aPosition forUniform:positionUniform program:filterProgram];
}

- (void)setAspect:(CGPoint)aAspect {
    [self setPoint:aAspect forUniform:aspectUniform program:filterProgram];
}

- (void)setScale:(CGFloat)aScale {
    [self setFloat:aScale forUniform:scaleUniform program:filterProgram];
}

@end
