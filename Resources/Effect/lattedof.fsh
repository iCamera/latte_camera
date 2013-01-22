/*
 Created by Martins Upitis
 I got this from here:
 http://artmartinsh.blogspot.jp/2010/02/glsl-lens-blur-filter-with-bokeh.html
 */

precision highp float;

varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform float bias; //0.02 aperture - bigger values for shallower depth of field

float blurclamp = 3.0;  // 3.0 max blur amount 
float focus = 0.0;  // this value comes from ReadDepth script.
float threshold = 0.1; //highlight threshold;

uniform float gain; //highlight gain;
uniform float imageWidthFactor; 
uniform float imageHeightFactor; 
uniform lowp float aspectratio;

vec4 color(vec4 col, float blur) //processing the sample
{
        vec3 lumcoeff = vec3(0.299,0.587,0.114);
        float lum = dot(col.rgb, lumcoeff);
        float thresh = max((lum-threshold)*gain, 0.0);
        return col+mix(vec4(0.0),col,thresh*blur);
}
 
void main()
{
        //float aspectratio = 800.0/600.0;
        lowp vec2 texel = vec2(imageWidthFactor,imageHeightFactor);
        vec2 aspectcorrect = vec2(1.0,1.0/aspectratio);
       
        vec4 depth1   = texture2D(inputImageTexture2,textureCoordinate2 );
 
        float factor = ( depth1.x - focus );
         
        vec2 dofblur = vec2 (clamp( factor * bias, -blurclamp, blurclamp ));
 
        vec4 col = vec4(0.0);
       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.0,0.4 )*aspectcorrect) * dofblur);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.15,0.37 )*aspectcorrect) * dofblur);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.29,0.29 )*aspectcorrect) * dofblur);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.37,0.15 )*aspectcorrect) * dofblur);       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.4,0.0 )*aspectcorrect) * dofblur);   
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.37,-0.15 )*aspectcorrect) * dofblur);       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.29,-0.29 )*aspectcorrect) * dofblur);       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.15,-0.37 )*aspectcorrect) * dofblur);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.0,-0.4 )*aspectcorrect) * dofblur); 
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.15,0.37 )*aspectcorrect) * dofblur);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.29,0.29 )*aspectcorrect) * dofblur);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.37,0.15 )*aspectcorrect) * dofblur); 
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.4,0.0 )*aspectcorrect) * dofblur); 
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.37,-0.15 )*aspectcorrect) * dofblur);       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.29,-0.29 )*aspectcorrect) * dofblur);       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.15,-0.37 )*aspectcorrect) * dofblur);
       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.15,0.37 )*aspectcorrect) * dofblur*0.9);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.37,0.15 )*aspectcorrect) * dofblur*0.9);           
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.37,-0.15 )*aspectcorrect) * dofblur*0.9);           
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.15,-0.37 )*aspectcorrect) * dofblur*0.9);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.15,0.37 )*aspectcorrect) * dofblur*0.9);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.37,0.15 )*aspectcorrect) * dofblur*0.9);            
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.37,-0.15 )*aspectcorrect) * dofblur*0.9);   
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.15,-0.37 )*aspectcorrect) * dofblur*0.9);   
       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.29,0.29 )*aspectcorrect) * dofblur*0.7);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.4,0.0 )*aspectcorrect) * dofblur*0.7);       
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.29,-0.29 )*aspectcorrect) * dofblur*0.7);   
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.0,-0.4 )*aspectcorrect) * dofblur*0.7);     
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.29,0.29 )*aspectcorrect) * dofblur*0.7);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.4,0.0 )*aspectcorrect) * dofblur*0.7);     
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.29,-0.29 )*aspectcorrect) * dofblur*0.7);   
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.0,0.4 )*aspectcorrect) * dofblur*0.7);
                         
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.29,0.29 )*aspectcorrect) * dofblur*0.4);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.4,0.0 )*aspectcorrect) * dofblur*0.4);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.29,-0.29 )*aspectcorrect) * dofblur*0.4);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.0,-0.4 )*aspectcorrect) * dofblur*0.4);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.29,0.29 )*aspectcorrect) * dofblur*0.4);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.4,0.0 )*aspectcorrect) * dofblur*0.4);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( -0.29,-0.29 )*aspectcorrect) * dofblur*0.4);
        col += texture2D(inputImageTexture, textureCoordinate + (vec2( 0.0,0.4 )*aspectcorrect) * dofblur*0.4);
                       
        col /= 41.0;
        gl_FragColor = color(col, factor);
        gl_FragColor.a = 1.0;
}