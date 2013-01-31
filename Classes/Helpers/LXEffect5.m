//
//  LXEffect5.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/30.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXEffect5.h"

NSString *const kLXEffect5Fragment = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D toneCurveTexture;
 
 const lowp vec4 exclusionBlend = vec4(44.0/255.0, 37.0/255.0, 94.0/255.0, 0.2);
 const lowp vec4 colorBlend = vec4(144.0/255.0, 120.0/255.0, 120.0/255.0, 0.5);
 
 highp float lum(lowp vec3 c) {
     return dot(c, vec3(0.3, 0.59, 0.11));
 }
 
 lowp vec3 clipcolor(lowp vec3 c) {
     highp float l = lum(c);
     lowp float n = min(min(c.r, c.g), c.b);
     lowp float x = max(max(c.r, c.g), c.b);
     
     if (n < 0.0) {
         c.r = l + ((c.r - l) * l) / (l - n);
         c.g = l + ((c.g - l) * l) / (l - n);
         c.b = l + ((c.b - l) * l) / (l - n);
     }
     if (x > 1.0) {
         c.r = l + ((c.r - l) * (1.0 - l)) / (x - l);
         c.g = l + ((c.g - l) * (1.0 - l)) / (x - l);
         c.b = l + ((c.b - l) * (1.0 - l)) / (x - l);
     }
     
     return c;
 }
 
 lowp vec3 setlum(lowp vec3 c, highp float l) {
     highp float d = l - lum(c);
     c = c + vec3(d);
     return clipcolor(c);
 }
 
 void main()
 {
     lowp vec4 base = texture2D(inputImageTexture, textureCoordinate);
     
     base = vec4((exclusionBlend.rgb * base.a + base.rgb * exclusionBlend.a - 2.0 * exclusionBlend.rgb * base.rgb) + exclusionBlend.rgb * (1.0 - base.a) + base.rgb * (1.0 - exclusionBlend.a), base.a);
     
     base = vec4(base.rgb * (1.0 - colorBlend.a) + setlum(colorBlend.rgb, lum(base.rgb)) * colorBlend.a, base.a);
     
     lowp float redCurveValue = texture2D(toneCurveTexture, vec2(base.r, 0.0)).r;
     lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(base.g, 0.0)).g;
     lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(base.b, 0.0)).b;
     
     gl_FragColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, 1.0);
 }
 );

@implementation LXEffect5

- (id)init;
{
    
    if (!(self = [super initWithFragmentShaderFromString:kLXEffect5Fragment]))
    {
		return nil;
    }
    
    toneCurveTextureUniform = [filterProgram uniformIndex:@"toneCurveTexture"];
    UIImage *imageMap = [UIImage imageNamed:@"effect5curve.png"];
    [self initCurveMap:imageMap.CGImage];
    
    return self;
}


@end
