/*
 DoF with bokeh GLSL shader v2.4
 by Martins Upitis (martinsh) (devlog-martinsh.blogspot.com)
 
 ----------------------
 The shader is Blender Game Engine ready, but it should be quite simple to adapt for your engine.
 
 This work is licensed under a Creative Commons Attribution 3.0 Unported License.
 So you are free to share, modify and adapt it for your needs, and even use it for commercial use.
 I would also love to hear about a project you are using it.
 
 Have fun,
 Martins
 ----------------------
 
 changelog:
 
 2.4:
 - physically accurate DoF simulation calculated from "focalDepth" ,"focalLength", "f-stop" and "CoC" parameters.
 - option for artist controlled DoF simulation calculated only from "focalDepth" and individual controls for near and far blur
 - added "circe of confusion" (CoC) parameter in mm to accurately simulate DoF with different camera sensor or film sizes
 - cleaned up the code
 - some optimization
 
 2.3:
 - new and physically little more accurate DoF
 - two extra input variables - focal length and aperture iris diameter
 - added a debug visualization of focus point and focal range
 
 2.1:
 - added an option for pentagonal bokeh shape
 - minor fixes
 
 2.0:
 - variable sample count to increase quality/performance
 - option to blur depth buffer to reduce hard edges
 - option to dither the samples with noise or pattern
 - bokeh chromatic aberration/fringing
 - bokeh bias to bring out bokeh edges
 - image thresholding to bring out highlights when image is out of focus
 
 */

#define PI  3.14159265

precision highp float;

varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

uniform mediump float width; //texture width
uniform mediump float height; //texture height

lowp vec2 texel = vec2(1.0/width,1.0/height);

//uniform variables from external script

uniform mediump float focalDepth;  //focal distance value in meters, but you may use autofocus option below
mediump float focalLength = 3.0; //focal length in mm
mediump float fstop = 2.8; //f-stop value
/*
 make sure that these two values are the same for your camera, otherwise distances will be wrong.
 */

mediump float znear = 0.1; //camera clipping start
mediump float zfar = 100.0; //camera clipping end

//------------------------------------------
//user variables

int samples = 4; //samples on the first ring
int rings = 2; //ring count


mediump float CoC = 0.03;//circle of confusion size in mm (35mm film = 0.03mm)

lowp float vignout = 1.3; //vignetting outer border
lowp float vignin = 0.0; //vignetting inner border
mediump float vignfade = 22.0; //f-stops till vignete fades

uniform bool autofocus; //use autofocus in shader? disable if you use external focalDepth value
uniform vec2 focus; // autofocus point on screen (0.0,0.0 - left lower corner, 1.0,1.0 - upper right)
uniform float maxblur; //clamp value of max blur (0.0 = no blur,1.0 default)

float threshold = 0.5; //highlight threshold;
uniform float gain; //highlight gain;

float bias = 0.5; //bokeh edge bias
float fringe = 0.7; //bokeh chromatic aberration/fringing

lowp float namount = 0.0001; //dither amount

/*
 next part is experimental
 not looking good with small sample and ring count
 looks okay starting from samples = 4, rings = 4
 */

//------------------------------------------


vec3 color(vec2 coords,float blur) //processing the sample
{
	vec3 col = vec3(0.0);
	
	col.r = texture2D(inputImageTexture,coords + vec2(0.0,1.0)*texel*fringe*blur).r;
	col.g = texture2D(inputImageTexture,coords + vec2(-0.866,-0.5)*texel*fringe*blur).g;
	col.b = texture2D(inputImageTexture,coords + vec2(0.866,-0.5)*texel*fringe*blur).b;
	
	vec3 lumcoeff = vec3(0.299,0.587,0.114);
	float lum = dot(col.rgb, lumcoeff);
	float thresh = max((lum-threshold)*gain, 0.0);
	return col+mix(vec3(0.0),col,thresh*blur);
}

vec2 rand(vec2 coord) //generating noise/pattern texture for dithering
{
	float noiseX = ((fract(1.0-coord.s*(width/2.0))*0.25)+(fract(coord.t*(height/2.0))*0.75))*2.0-1.0;
	float noiseY = ((fract(1.0-coord.s*(width/2.0))*0.75)+(fract(coord.t*(height/2.0))*0.25))*2.0-1.0;
	
	return vec2(noiseX,noiseY);
}

float linearize(float depth)
{
	return -zfar * znear / (depth * (zfar - znear) - zfar);
}

void main()
{
	//scene depth calculation
	
	mediump float depth = linearize(1.0 - texture2D(inputImageTexture2, textureCoordinate2).a);
	
	//focal plane calculation
	
	mediump float fDepth = focalDepth;
	
	if (autofocus)
	{
		fDepth = linearize(1.0 - texture2D(inputImageTexture2,focus).a);
	}
	
	//dof blur factor calculation
	
	float blur = 0.0;
	
	
	float f = focalLength; //focal length in mm
	float d = fDepth*1000.0; //focal plane in mm
	float o = depth*1000.0; //depth in mm
	
	float a = (o*f)/(o-f);
	float b = (d*f)/(d-f);
	float c = (d-f)/(d*fstop*CoC);
	
	blur = abs(a-b)*c;
	
	blur = clamp(blur,0.0,1.0);
	
	// calculation of pattern for ditering
	
	vec2 noise = rand(textureCoordinate.xy)*namount*blur;
	
	// getting blur x and y step factor
	
	float w = (1.0/width)*blur*maxblur+noise.x;
	float h = (1.0/height)*blur*maxblur+noise.y;
	
	// calculation of final color
	
	mediump vec3 col = vec3(0.0);
	
	//if(blur < 0.05) //some optimization thingy
	//{
	//	col = texture2D(inputImageTexture, textureCoordinate).rgb;
	//}
	
	//else
	//{
		col = texture2D(inputImageTexture, textureCoordinate).rgb;
		float s = 1.0;
		int ringsamples;
		
		for (int i = 1; i <= rings; i += 1)
		{
			ringsamples = i * samples;
			
			for (int j = 0 ; j < ringsamples ; j += 1)
			{
				float step = PI*2.0 / float(ringsamples);
				float pw = (cos(float(j)*step)*float(i));
				float ph = (sin(float(j)*step)*float(i));
				float p = 1.0;
				
				col += color(textureCoordinate.xy + vec2(pw*w,ph*h),blur)*mix(1.0,(float(i))/(float(rings)),bias)*p;
				s += 1.0*mix(1.0,(float(i))/(float(rings)),bias)*p;
			}
		}
		col /= s; //divide by sample count
	//}
	
	gl_FragColor = vec4(col, 1.0);
}
