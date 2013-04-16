/*
 Created by Xuan Dung Bui
 */

precision highp float;

varying highp vec2 textureCoordinate;
varying highp vec2 dofCoordinate;
varying highp vec2 blendCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D toneCurveTexture;
uniform sampler2D inputBlendTexture;
uniform sampler2D inputDOFTexture;

uniform lowp float vignfade; //f-stops till vignete fades
uniform lowp float brightness;

uniform lowp float clearness;
uniform lowp float saturation;
uniform lowp float aspectratio;

uniform lowp float toneIntensity;
uniform lowp float blendIntensity;

uniform bool toneEnable;
uniform bool blendEnable;

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
    highp float dist = distance(vec2(textureCoordinate.x, (textureCoordinate.y * aspectratio + 0.5 - 0.5 * aspectratio)), vec2(0.5,0.5));
    dist = smoothstep(vignout+vignfade, vignin+vignfade, dist);
    return clamp(dist,0.0,1.0);
}

/// <summary>
/// 2D Noise by Ian McEwan, Ashima Arts.
/// <summary>
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }
float snoise (vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626, // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0

    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);

    // Other corners
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
        + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;

    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
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
    textureColor.rgb += vec3(brightness);

    // Contrast
    //vec3 conColor = mix(averageColor, satColor, 1.0);
    
    // textureColor.rgb = conColor;

    // Vignette
    textureColor.rgb *= vignette();

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

    // Saturation
    luminance = dot(textureColor.rgb, luminanceWeighting);
    textureColor = vec4(mix(vec3(luminance), textureColor.rgb, saturation), textureColor.a);

    //Add noise
    if (false) {
        float noise = snoise(textureCoordinate * vec2(1024.0 + 0.5 * 512.0, 1024.0 + 0.5 * 512.0)) * 0.5;
        textureColor.rgb += vec3(noise)*0.10;
    }

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