/*
 Created by Xuan Dung Bui
 */

precision highp float;

varying highp vec2 textureCoordinate;
varying highp vec2 dofCoordinate;
varying highp vec2 blendCoordinate;
varying highp vec2 filmCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D toneCurveTexture;
uniform sampler2D inputBlendTexture;
uniform sampler2D inputDOFTexture;
uniform sampler2D inputFilmTexture;

uniform lowp float vignfade; //f-stops till vignete fades
uniform lowp float brightness;

uniform lowp float clearness;
uniform lowp float saturation;
uniform lowp float aspectratio;

uniform lowp float toneIntensity;
uniform lowp float blendIntensity;
uniform lowp float filmIntensity;

uniform bool toneEnable;
uniform bool blendEnable;
uniform bool filmEnable;

lowp float vignin = 0.0; //vignetting inner border
lowp float vignout = 0.5; //vignetting outer border

float aperture = 180.0;
const float PI = 3.1415926535;
const highp vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);


//BEGIN FOR DEF
uniform bool dofEnable;
uniform float bias; //0.02 aperture - bigger values for shallower depth of field

float blurclamp = 3.0;  // 3.0 max blur amount 
float focus = 0.0;  // this value comes from ReadDepth script.
float threshold = 0.5; //highlight threshold;

uniform float gain; //highlight gain;
//END FOR DOF

vec4 color(vec4 col, float blur) //processing the sample
{
        vec3 lumcoeff = vec3(0.299,0.587,0.114);
        float lum = dot(col.rgb, lumcoeff);
        float thresh = max((lum-threshold)*gain, 0.0);
        return col+mix(vec4(0.0),col,thresh*blur);
}
 
vec4 dof()
{
        //float aspectratio = 800.0/600.0;
        vec2 aspectcorrect = vec2(1.0,1.0/aspectratio);
       
        vec4 depth1 = texture2D(inputDOFTexture, dofCoordinate);
 
        float factor = ( depth1.x - focus );
         
        vec2 dofblur = vec2 (clamp( factor * bias, -blurclamp, blurclamp ));
 
        vec4 col = texture2D(inputImageTexture, textureCoordinate);
       
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

        col = color(col, factor);
        col.a = 1.0;
        return col;
}

float vignette()
{
    highp float dist = distance(textureCoordinate, vec2(0.5,0.5));
    dist = smoothstep(vignout+(1.0-vignfade), vignin+(1.0-vignfade), dist);
    return clamp(dist,0.0,1.0);
}

void main()
{
    lowp vec4 textureColor;
    if (dofEnable)
        textureColor = dof();
    else
        textureColor = texture2D(inputImageTexture, textureCoordinate);

    lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
    lowp float average = (textureColor.r + textureColor.g + textureColor.b)/3.0;
    lowp vec3 greyScaleColor = vec3(luminance);
    // lowp vec3 averageColor = vec3(average);

    // Brightness
    textureColor.rgb = vec3(textureColor.rgb * pow(2.0, brightness));

    // Contrast
    //vec3 conColor = mix(averageColor, satColor, 1.0);
    
    // textureColor.rgb = conColor;

    // Overlay
    if (clearness > 0.0) {
        if (textureColor.r < 0.5) {
            textureColor.r = 2.0 * luminance * textureColor.r * clearness + textureColor.r * (1.0 - clearness);
        } else {
            textureColor.r = (1.0 - 2.0 * (1.0 - textureColor.r) * (1.0 - luminance)) * clearness + textureColor.r * (1.0 - clearness);
        }
        if (textureColor.g < 0.5) {
            textureColor.g = 2.0 * luminance * textureColor.g * clearness + textureColor.g * (1.0 - clearness);
        } else {
            textureColor.g = (1.0 - 2.0 * (1.0 - textureColor.g) * (1.0 - luminance)) * clearness + textureColor.g * (1.0 - clearness);
        }
        if (textureColor.b < 0.5) {
            textureColor.b = 2.0 * luminance * textureColor.b * clearness + textureColor.b * (1.0 - clearness);
        } else {
            textureColor.b = (1.0 - 2.0 * (1.0 - textureColor.b) * (1.0 - luminance)) * clearness + textureColor.b * (1.0 - clearness);
        }
    }

    // Blending
    if (blendEnable) {
        mediump vec4 textureBlend = texture2D(inputBlendTexture, blendCoordinate);
        textureBlend *= blendIntensity;
        mediump vec4 whiteColor = vec4(1.0);
        textureColor = whiteColor - ((whiteColor - textureBlend) * (whiteColor - textureColor));
    }

    // Film
    if (filmEnable) {
        mediump vec4 textureFilm = texture2D(inputFilmTexture, filmCoordinate);
        textureFilm *= filmIntensity;
        mediump vec4 whiteColor = vec4(1.0);
        textureColor = whiteColor - ((whiteColor - textureFilm) * (whiteColor - textureColor));
    }

    // Saturation
    luminance = dot(textureColor.rgb, luminanceWeighting);
    textureColor = vec4(mix(vec3(luminance), textureColor.rgb, saturation), textureColor.a);

    // Vignette
    textureColor.rgb *= vignette();

    // Tone Curve Mapping
    if (toneEnable) {
        lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
        lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
        lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
         
        textureColor = vec4(mix(textureColor.rgb, vec3(redCurveValue, greenCurveValue, blueCurveValue), toneIntensity), textureColor.a);
    }

    // End
    gl_FragColor = textureColor;
}