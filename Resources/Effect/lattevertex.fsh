 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 blendTextureCoordinate;
 
 varying vec2 textureCoordinate;
 varying vec2 blendCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     blendCoordinate = blendTextureCoordinate.xy;
 }
