uniform sampler2D Texture;
varying vec2 TexCoord;
uniform float margin_h;
uniform float margin_v;

void main()
{
  float q = min((1.0-TexCoord.s)/margin_h, TexCoord.s/margin_h);
  float r = min((1.0-TexCoord.t)/margin_v, TexCoord.t/margin_v);
  float p = min(q,r);
  gl_FragColor = vec4(0,0,0,p);
}

