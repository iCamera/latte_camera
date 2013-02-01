//
//  LXEffect2.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/29.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXEffect2.h"

NSString *const kLXEffect2Fragment = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const lowp vec4 solidBlend = vec4(0.9607, 0.7960, 0.2313, 1.0);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
     lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
     lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     
     textureColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);
     
     gl_FragColor = mix(textureColor, solidBlend * textureColor, 0.095);
 }
);

@implementation LXEffect2

- (id)init;
{
    
    if (!(self = [super initWithFragmentShaderFromString:kLXEffect2Fragment]))
    {
		return nil;
    }
    
    toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
    UIImage *imageMap = [UIImage imageNamed:@"effect2curve.png"];
    [self initCurveMap:imageMap.CGImage];
    
    return self;
}

@end
