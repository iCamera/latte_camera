 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 blendTextureCoordinate;
 attribute vec4 filmTextureCoordinate;
 attribute vec4 textTextureCoordinate;
 
 varying vec2 textureCoordinate;
 varying vec2 blendCoordinate;
 varying vec2 filmCoordinate;
 varying vec2 textCoordinate;

 uniform float imageWidthFactor; 
 uniform float imageHeightFactor; 
 uniform float sharpness;
 
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate; 
 varying vec2 topTextureCoordinate;
 varying vec2 bottomTextureCoordinate;
 
 varying float centerMultiplier;
 varying float edgeMultiplier;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     blendCoordinate = blendTextureCoordinate.xy;
     filmCoordinate = filmTextureCoordinate.xy;
     textCoordinate = textTextureCoordinate.xy;

     vec2 widthStep = vec2(imageWidthFactor, 0.0);
     vec2 heightStep = vec2(0.0, imageHeightFactor);

     leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
     rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
     topTextureCoordinate = inputTextureCoordinate.xy + heightStep;
     bottomTextureCoordinate = inputTextureCoordinate.xy - heightStep;
     
     centerMultiplier = 1.0 + 4.0 * sharpness;
     edgeMultiplier = sharpness;
 }
