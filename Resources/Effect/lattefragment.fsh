precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

uniform lowp float vignfade; //f-stops till vignete fades
uniform lowp float brightness;
uniform sampler2D gradientMapTexture;
uniform sampler2D toneCurveTexture;
uniform lowp float clearness;
uniform lowp float gradient;
uniform lowp float saturation;
uniform lowp float aspectratio;

lowp float vignin = 0.0; //vignetting inner border
lowp float vignout = 0.5; //vignetting outer border

float aperture = 180.0;
const float PI = 3.1415926535;
const highp vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);


float vignette()
{
    highp float dist = distance(vec2(textureCoordinate.x, (textureCoordinate.y * aspectratio + 0.5 - 0.5 * aspectratio)), vec2(0.5,0.5));
    dist = smoothstep(vignout+vignfade, vignin+vignfade, dist);
    return clamp(dist,0.0,1.0);
}

void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);

    lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
    lowp float average = (textureColor.r + textureColor.g + textureColor.b)/3.0;
    lowp vec3 greyScaleColor = vec3(luminance);
    lowp vec3 averageColor = vec3(average);

    // Saturation
    vec3 satColor = mix(greyScaleColor, textureColor.rgb, saturation);
    // Brightness
    textureColor.rgb = satColor.rgb + vec3(brightness);
    // Contrast
    //vec3 conColor = mix(averageColor, satColor, 1.0);
    
    // textureColor.rgb = conColor;

    // Tone Curve Mapping
    if (false) {
        lowp float redCurveValue = texture2D(toneCurveTexture, vec2(textureColor.r, 0.0)).r;
        lowp float greenCurveValue = texture2D(toneCurveTexture, vec2(textureColor.g, 0.0)).g;
        lowp float blueCurveValue = texture2D(toneCurveTexture, vec2(textureColor.b, 0.0)).b;
         
        textureColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, textureColor.a);
    }

    // Gradient Map
    if (gradient > 0.0) {
        textureColor.rgb = mix(textureColor.rgb, texture2D(gradientMapTexture, vec2(luminance, 0.0)).rgb, gradient);
    }

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

    // End
    gl_FragColor = textureColor;
}