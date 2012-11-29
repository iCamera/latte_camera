
#import "LXFilterBlur.h"

@implementation LXFilterBlur

@synthesize focus;
@synthesize maxblur;
@synthesize focalDepth;
@synthesize autofocus;
@synthesize gain;
@synthesize threshold;

- (id)init;
{
    NSString *shader = @"#define PI 3.14159265\n"
    "precision highp float;\n"
    "varying highp vec2 textureCoordinate;\n"
    "varying highp vec2 textureCoordinate2;\n"
    "uniform sampler2D inputImageTexture;\n"
    "uniform sampler2D inputImageTexture2;\n"
    "uniform mediump float width;\n"
    "uniform mediump float height;\n"
    "uniform mediump float focalDepth;\n"
    "lowp vec2 texel = vec2(1.0/width,1.0/height);\n"
    "mediump float focalLength = 3.0;\n"
    "mediump float fstop = 2.8;\n"
    "mediump float znear = 0.1;\n"
    "mediump float zfar = 100.0;\n"
    "uniform int samples;\n"
    "uniform int rings;\n"
    "mediump float CoC = 0.03;\n"
    "uniform bool autofocus;\n"
    "uniform vec2 focus;\n"
    "uniform float maxblur;\n"
    "uniform float gain;\n"
    "float threshold = 0.5;\n"
    "float bias = 0.5;\n"
    "float fringe = 0.7;\n"
    "lowp float namount = 0.0001;\n"
    "vec3 color(vec2 coords,float blur)\n"
    "{\n"
	"vec3 col = vec3(0.0);\n"
    "	\n"
	"col.r = texture2D(inputImageTexture,coords + vec2(0.0,1.0)*texel*fringe*blur).r;\n"
	"col.g = texture2D(inputImageTexture,coords + vec2(-0.866,-0.5)*texel*fringe*blur).g;\n"
	"col.b = texture2D(inputImageTexture,coords + vec2(0.866,-0.5)*texel*fringe*blur).b;\n"
    "	\n"
	"vec3 lumcoeff = vec3(0.299,0.587,0.114);\n"
	"float lum = dot(col.rgb, lumcoeff);\n"
	"float thresh = max((lum-threshold)*gain, 0.0);\n"
	"return col+mix(vec3(0.0),col,thresh*blur);\n"
    "}\n"
    " \n"
    "vec2 rand(vec2 coord)\n"
    "{\n"
	"float noiseX = ((fract(1.0-coord.s*(width/2.0))*0.25)+(fract(coord.t*(height/2.0))*0.75))*2.0-1.0;\n"
	"float noiseY = ((fract(1.0-coord.s*(width/2.0))*0.75)+(fract(coord.t*(height/2.0))*0.25))*2.0-1.0;\n"
    "	\n"
	"return vec2(noiseX,noiseY);\n"
    "}\n"
    " \n"
    "float linearize(float depth)\n"
    "{\n"
	"return -zfar * znear / (depth * (zfar - znear) - zfar);\n"
    "}\n"
    " \n"
    "void main()\n"
    "{\n"
	"mediump float depth = linearize(texture2D(inputImageTexture2, textureCoordinate2).a);\n"
	"mediump float fDepth = focalDepth;\n"
    "	\n"
	"if (autofocus)\n"
	"{\n"
    "fDepth = linearize(texture2D(inputImageTexture2,focus).a);\n"
	"}\n"
	"float blur = 0.0;\n"
    "	\n"
	"float f = focalLength;\n"
	"float d = fDepth*1000.0;\n"
	"float o = depth*1000.0;\n"
	"float a = (o*f)/(o-f);\n"
	"float b = (d*f)/(d-f);\n"
	"float c = (d-f)/(d*fstop*CoC);\n"
	"blur = abs(a-b)*c;\n"
	"blur = clamp(blur,0.0,1.0);\n"
	"vec2 noise = rand(textureCoordinate.xy)*namount*blur;\n"
    "	\n"
	"float w = (1.0/width)*blur*maxblur+noise.x;\n"
	"float h = (1.0/height)*blur*maxblur+noise.y;\n"
    "		\n"
	"mediump vec3 col = vec3(0.0);\n"
    "	\n"
	"if(blur < 0.05)\n"
	"{\n"
    "col = texture2D(inputImageTexture, textureCoordinate).rgb;\n"
	"}\n"
    "	\n"
	"else\n"
	"{\n"
    "col = texture2D(inputImageTexture, textureCoordinate).rgb;\n"
    "float s = 1.0;\n"
    "int ringsamples;\n"
    "		\n"
    "for (int i = 1; i <= rings; i += 1)\n"
    "{\n"
    "ringsamples = i * samples;\n"
    "			\n"
    "for (int j = 0 ; j < ringsamples ; j += 1)\n"
    "{\n"
    "float step = PI*2.0 / float(ringsamples);\n"
    "float pw = (cos(float(j)*step)*float(i));\n"
    "float ph = (sin(float(j)*step)*float(i));\n"
    "float p = 1.0;\n"
    "				\n"
    "col += color(textureCoordinate.xy + vec2(pw*w,ph*h),blur)*mix(1.0,(float(i))/(float(rings)),bias)*p;\n"
    "s += 1.0*mix(1.0,(float(i))/(float(rings)),bias)*p;\n"
    "}\n"
    "}\n"
    "col /= s;\n"
	"}\n"
	"gl_FragColor = vec4(col, 1.0);\n"
    "}\n";
    
    if (!(self = [super initWithFragmentShaderFromString:shader]))
    {
		return nil;
    }
    
    focusUniform = [filterProgram uniformIndex:@"focus"];
    
    widthUniform = [filterProgram uniformIndex:@"width"];
    heightUniform = [filterProgram uniformIndex:@"height"];
    
    maxblurUniform = [filterProgram uniformIndex:@"maxblur"];
    focalDepthUniform = [filterProgram uniformIndex:@"focalDepth"];
    
    autofocusUniform = [filterProgram uniformIndex:@"autofocus"];
    gainUniform = [filterProgram uniformIndex:@"gain"];
    
    thresholdUniform = [filterProgram uniformIndex:@"threshold"];
    
    samplesUniform = [filterProgram uniformIndex:@"samples"];
    ringsUniform = [filterProgram uniformIndex:@"rings"];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    if (screen.size.height < 568.0) //not iphone 5
    {
        [self setInteger:2 forUniform:ringsUniform program:filterProgram];
        [self setInteger:3 forUniform:samplesUniform program:filterProgram];
    } else {
        [self setInteger:3 forUniform:ringsUniform program:filterProgram];
        [self setInteger:4 forUniform:samplesUniform program:filterProgram];
    }
    
    //    [self setAutofocus:true];
    //    [self setFocus:CGPointMake(0.5, 0.5)];
    //    [self setMaxblur:0.5];
    //    [self setgain:1.25];
    
    return self;
}

- (void)setFocus:(CGPoint)aFocus {
    focus = aFocus;
    [self setPoint:focus forUniform:focusUniform program:filterProgram];
}

- (void)setMaxblur:(CGFloat)aMaxblur {
    maxblur = aMaxblur;
    [self setFloat:maxblur forUniform:maxblurUniform program:filterProgram];
}

- (void)setFocalDepth:(CGFloat)aFocalDepth {
    focalDepth = aFocalDepth;
    [self setFloat:focalDepth forUniform:focalDepthUniform program:filterProgram];
}

- (void)setAutofocus:(BOOL)aAutofocus {
    autofocus = aAutofocus;
    [self setInteger:autofocus forUniform:autofocusUniform program:filterProgram];
}
- (void)setThreshold:(CGFloat)aThreshold {
    threshold = aThreshold;
    [self setFloat:threshold forUniform:thresholdUniform program:filterProgram];
}

- (void)setGain:(CGFloat)aGain {
    gain = aGain;
    [self setFloat:gain forUniform:gainUniform program:filterProgram];
}

- (void)setFrameSize:(CGSize)frameSize {
    [self setFloat:frameSize.width forUniform:widthUniform program:filterProgram];
    [self setFloat:frameSize.height forUniform:heightUniform program:filterProgram];
}

/*
 - (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
 {
 if (self.preventRendering)
 {
 return;
 }
 
 [GPUImageOpenGLESContext setActiveShaderProgram:filterProgram];
 [self setFilterFBO];
 
 glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
 glClear(GL_COLOR_BUFFER_BIT);
 
 glActiveTexture(GL_TEXTURE2);
 glBindTexture(GL_TEXTURE_2D, sourceTexture);
 glUniform1i(filterInputTextureUniform, 2);
 
 glActiveTexture(GL_TEXTURE3);
 glBindTexture(GL_TEXTURE_2D, depthTexture);
 glUniform1i(depthTextureUniform, 3);
 
 glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
 glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
 
 glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
 }
 
 - (void)dealloc
 {
 if (depthTexture)
 {
 glDeleteTextures(1, &depthTexture);
 depthTexture = 0;
 free(depthMapByteArray);
 }
 }*/

@end
