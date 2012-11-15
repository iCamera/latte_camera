//
//  LXFilterFish.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/14.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXFilterFish.h"

NSString *const kLXFilterFishVertex = SHADER_STRING
(
 varying vec4 normal;
 varying vec4 light_dir;
 varying vec4 eye_vec;
 varying vec4 lookat;
 const float PI =  3.14159265;
 void main()
 {
     vec4 ambient;
     vec4 diffuse;
     vec4 specular;
     float NdotL;
     float RdotV;
     normal = vec4(gl_NormalMatrix * gl_Normal, 0.0);
     vec4 vVertex = gl_ModelViewMatrix * gl_Vertex;
     light_dir = gl_LightSource[0].position - vVertex;
     eye_vec = -vVertex;
     
     vec4 temp_pos = ftransform();
     
     float dist = length(eye_vec);
     lookat = eye_vec - temp_pos;
     vec4 dir = temp_pos - eye_vec;
     vec4 center = normalize(-eye_vec);
     vec4 proj = dot(temp_pos, normalize(-lookat)) * normalize(-lookat);
     
     vec4 c = temp_pos - proj;
     
     float magnitude = .01;//1-acos(dot(normalize(-eye_vec), normalize(temp_pos)));
     
     c = length(c) * magnitude * normalize(c);
     
     vec4 dir2 = normalize(c-lookat);
     
     dir2 = (dir2 * dist);
     
     gl_Position.xyz = dir2.xyz;
     gl_Position.w = ftransform().w;
     
     gl_FrontColor = gl_Color;
     gl_TexCoord[0] = gl_MultiTexCoord0;
 }
);

NSString *const kLXFilterFishFragment = SHADER_STRING
(
 varying vec4 normal;
 varying vec4 light_dir;
 varying vec4 eye_vec;
 uniform vec4 camera_pos;
 void main()
 {
     vec4 ambient;
     vec4 diffuse;
     vec4 specular;
     float NdotL;
     float RdotV;
     
     vec4 N = normalize(normal);
     vec4 L = normalize(light_dir);
     NdotL = dot(N, L);
     //RdotV = max(dot(R, V), 0.0);
     gl_FragColor = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
     
     if(NdotL > 0.0)
     {
         ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
         diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
         specular = gl_FrontMaterial.specular * gl_LightSource[0].specular;
         vec4 E = normalize(eye_vec);
         vec4 R = reflect(-L, N);
         
         gl_FragColor +=  (NdotL * diffuse) +
         specular * pow(max(dot(R, E), 0.0), gl_FrontMaterial.shininess);
     }
 }
 );

@implementation LXFilterFish


- (id)init;
{
    if (!(self = [super initWithVertexShaderFromString:kLXFilterFishVertex fragmentShaderFromString:kLXFilterFishFragment]))
    {
		return nil;
    }

    return self;
}

@end
