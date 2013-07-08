/*
 Created by Xuan Dung Bui
 */

precision mediump float;

varying highp vec2 textureCoordinate;
varying highp vec2 blendCoordinate;
varying highp vec2 filmCoordinate;
varying highp vec2 textCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D toneCurveTexture;
uniform sampler2D inputBlendTexture;
uniform sampler2D inputFilmTexture;
uniform sampler2D inputTextTexture;

uniform lowp float vignfade; //f-stops till vignete fades
uniform lowp float brightness;
uniform lowp float exposure;
uniform lowp float contrast;

uniform lowp float clearness;
uniform lowp float saturation;
uniform lowp float aspectratio;

uniform lowp float toneIntensity;
uniform lowp float blendIntensity;
uniform lowp float filmIntensity;

uniform bool toneEnable;
uniform bool blendEnable;
uniform bool filmEnable;
uniform bool textEnable;
uniform int blendMode;
uniform int filmMode;

lowp float vignin = 0.0; //vignetting inner border
lowp float vignout = 0.5; //vignetting outer border

const highp vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

// Sharpen
varying highp vec2 leftTextureCoordinate;
varying highp vec2 rightTextureCoordinate; 
varying highp vec2 topTextureCoordinate;
varying highp vec2 bottomTextureCoordinate;

varying highp float centerMultiplier;
varying highp float edgeMultiplier;

float vignette()
{
    highp float dist = distance(textureCoordinate, vec2(0.5,0.5));
    dist = smoothstep(vignout+(1.0-vignfade), vignin+(1.0-vignfade), dist);
    return clamp(dist,0.0,1.0);
}

vec4 blendcolordodge(vec4 base, vec4 overlay)
{
    vec3 baseOverlayAlphaProduct = vec3(overlay.a * base.a);
    vec3 rightHandProduct = overlay.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlay.a);
     
    vec3 firstBlendColor = baseOverlayAlphaProduct + rightHandProduct;
    vec3 overlayRGB = clamp((overlay.rgb / clamp(overlay.a, 0.01, 1.0)) * step(0.0, overlay.a), 0.0, 0.99);
     
    vec3 secondBlendColor = (base.rgb * overlay.a) / (1.0 - overlayRGB) + rightHandProduct;
     
    vec3 colorChoice = step((overlay.rgb * base.a + base.rgb * overlay.a), baseOverlayAlphaProduct);
     
    return vec4(mix(firstBlendColor, secondBlendColor, colorChoice), 1.0);
}

vec4 blendoverlay(vec4 base, vec4 overlay)
{
    mediump float ra;
    if (2.0 * base.r < base.a) {
        ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    } else {
        ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    }
    
    mediump float ga;
    if (2.0 * base.g < base.a) {
        ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    } else {
        ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    }
    
    mediump float ba;
    if (2.0 * base.b < base.a) {
        ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    } else {
        ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    }
    
    return vec4(ra, ga, ba, 1.0);
}

vec4 blendscreen(vec4 base, vec4 overlay)
{
    mediump vec4 whiteColor = vec4(1.0);
    return whiteColor - ((whiteColor - overlay) * (whiteColor - base));
}

vec4 blendmultiply(vec4 base, vec4 overlay)
{
    return overlay * base + overlay * (1.0 - base.a) + base * (1.0 - overlay.a);
}

vec4 blendsoftlight(vec4 base, vec4 overlay)
{
    return base * (overlay.a * (base / base.a) + (2.0 * overlay * (1.0 - (base / base.a)))) + overlay * (1.0 - base.a) + base * (1.0 - overlay.a);
}

vec4 blenddarken(vec4 base, vec4 overlay)
{
    return vec4(min(overlay.rgb * base.a, base.rgb * overlay.a) + overlay.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlay.a), 1.0);
}

vec4 blendlighten(vec4 base, vec4 overlay)
{
    return max(base, overlay);
}

vec4 blendnormal(vec4 base, vec4 overlay)
{
     mediump vec4 outputColor;
     mediump float a = overlay.a + base.a * (1.0 - overlay.a);
     outputColor.r = (overlay.r * overlay.a + base.r * base.a * (1.0 - overlay.a))/a;
     outputColor.g = (overlay.g * overlay.a + base.g * base.a * (1.0 - overlay.a))/a;
     outputColor.b = (overlay.b * overlay.a + base.b * base.a * (1.0 - overlay.a))/a;
     outputColor.a = a;
     return outputColor;
}

vec4 blendcolorburn(vec4 base, vec4 overlay)
{
    mediump vec4 whiteColor = vec4(1.0);
    return whiteColor - (whiteColor - base) / overlay;
}

vec4 blendhardlight(vec4 base, vec4 overlay)
{
    highp float ra;
    if (2.0 * overlay.r < overlay.a) {
        ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    } else {
        ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
    }
    
    highp float ga;
    if (2.0 * overlay.g < overlay.a) {
        ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    } else {
        ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
    }
    
    highp float ba;
    if (2.0 * overlay.b < overlay.a) {
        ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    } else {
        ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
    }
    
    return vec4(ra, ga, ba, 1.0);
}

vec4 blenddifference(vec4 base, vec4 overlay)
{
    return vec4(abs(overlay.rgb - base.rgb), base.a);
}

vec4 blendexclusion(vec4 base, vec4 overlay)
{
    return vec4((overlay.rgb * base.a + base.rgb * overlay.a - 2.0 * overlay.rgb * base.rgb) + overlay.rgb * (1.0 - base.a) + base.rgb * (1.0 - overlay.a), base.a);
}

vec4 blend(vec4 base, vec4 overlay, int mode) {
    if (mode == 0)
        return blenddarken(base, overlay);
    else if (mode == 1)
        return blendmultiply(base, overlay);
    else if (mode == 2)
        return blendcolorburn(base, overlay);
    else if (mode == 3)
        return blendlighten(base, overlay);
    else if (mode == 4)
        return blendscreen(base, overlay);
    else if (mode == 5)
        return blendcolordodge(base, overlay);
    else if (mode == 6)
        return blendoverlay(base, overlay);
    else if (mode == 7)
        return blendsoftlight(base, overlay);
    else if (mode == 8)
        return blendhardlight(base, overlay);
    else if (mode == 9)
        return blenddifference(base, overlay);
    else if (mode == 10)
        return blendexclusion(base, overlay);
    else
        return blendnormal(base, overlay);
}

void main()
{
    mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    if (edgeMultiplier > 0.0) {
        mediump vec3 leftTextureColor = texture2D(inputImageTexture, leftTextureCoordinate).rgb;
        mediump vec3 rightTextureColor = texture2D(inputImageTexture, rightTextureCoordinate).rgb;
        mediump vec3 topTextureColor = texture2D(inputImageTexture, topTextureCoordinate).rgb;
        mediump vec3 bottomTextureColor = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;

        textureColor = vec4((textureColor.rgb * centerMultiplier - (leftTextureColor * edgeMultiplier + rightTextureColor * edgeMultiplier + topTextureColor * edgeMultiplier + bottomTextureColor * edgeMultiplier)), texture2D(inputImageTexture, bottomTextureCoordinate).w);
    }

    mediump float luminance = dot(textureColor.rgb, luminanceWeighting);
    mediump float average = (textureColor.r + textureColor.g + textureColor.b)/3.0;
    mediump vec3 greyScaleColor = vec3(luminance);
    // lowp vec3 averageColor = vec3(average);

    // Exposure
    textureColor.rgb = textureColor.rgb * pow(2.0, exposure);

    // Brightness
    textureColor.rgb = textureColor.rgb + brightness;

    // Contrast
    textureColor.rgb = (textureColor.rgb - vec3(0.5)) * contrast + vec3(0.5);

    // Dynamic
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
        textureColor = mix(textureColor, blend(textureColor, textureBlend, blendMode), blendIntensity);
    }

    // Film
    if (filmEnable) {
        mediump vec4 textureFilm = texture2D(inputFilmTexture, filmCoordinate);
        textureColor = mix(textureColor, blend(textureColor, textureFilm, filmMode), filmIntensity);
    }

    // Saturation
    luminance = dot(textureColor.rgb, luminanceWeighting);
    textureColor = vec4(mix(vec3(luminance), textureColor.rgb, saturation), textureColor.a);

    // Vignette
    textureColor.rgb *= vignette();

    // Text
    if (textEnable) {
        lowp vec4 textureText = texture2D(inputTextTexture, textCoordinate);
        //textureColor.rgb = mix(textureColor.rgb, textureText.rgb, textureText.a);
        //fix premultiplied
        textureColor.rgb = textureText.rgb + (1.0 - textureText.a) * textureColor.rgb;
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