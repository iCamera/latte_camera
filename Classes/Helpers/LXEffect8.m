//
//  LXEffect8.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/13/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXEffect8.h"

NSString *const kLXEffect8Fragment = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
     lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
     lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
     
     gl_FragColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);
 }
 );

@implementation LXEffect8

- (id)init;
{
    
    if (!(self = [super initWithFragmentShaderFromString:kLXEffect8Fragment]))
    {
		return nil;
    }
    
    toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
    UIImage *imageMap = [UIImage imageNamed:@"effect8curve.png"];
    [self initCurveMap:imageMap.CGImage];
    
    return self;
}

@end
