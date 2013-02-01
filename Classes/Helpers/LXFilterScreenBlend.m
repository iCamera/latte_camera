//
//  LXFilterScreenBlend.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/28.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXFilterScreenBlend.h"

NSString *const kLXScreenBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float mixturePercent;
 
 void main()
 {
     mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     mediump vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     textureColor2 *= mixturePercent;
     mediump vec4 whiteColor = vec4(1.0);
     gl_FragColor = whiteColor - ((whiteColor - textureColor2) * (whiteColor - textureColor));
 }
 );

@implementation LXFilterScreenBlend

@synthesize mix;

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kLXScreenBlendFragmentShaderString]))
    {
		return nil;
    }
    
    mixUniform = [filterProgram uniformIndex:@"mixturePercent"];
    self.mix = 0.5;
    
    return self;
}

- (void)setMix:(CGFloat)aMix {
    [self setFloat:aMix forUniform:mixUniform program:filterProgram];
}

@end
