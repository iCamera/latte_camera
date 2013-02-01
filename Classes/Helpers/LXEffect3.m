//
//  LXEffect3.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/29.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXEffect3.h"

NSString *const kLXEffect3Fragment = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 const lowp vec4 softBlend = vec4(0.5372, 0.5215, 0.4274, 1.0);
 const lowp vec4 lightenBlend = vec4(0.4117, 0.3098, 0.2392, 1.0);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     textureColor = textureColor * (softBlend.a * (textureColor / textureColor.a) + (2.0 * softBlend * (1.0 - (textureColor / textureColor.a)))) + softBlend * (1.0 - textureColor.a) + textureColor * (1.0 - softBlend.a);
     
     lowp vec4 lightenColor = max(textureColor, lightenBlend);
     gl_FragColor = mix(textureColor, lightenColor, 0.55);
 }
 );

@implementation LXEffect3


- (id)init;
{
    
    if (!(self = [super initWithFragmentShaderFromString:kLXEffect3Fragment]))
    {
		return nil;
    }
    
    return self;
}

@end
