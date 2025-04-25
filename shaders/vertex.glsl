#version 450 
precision highp float;
in vec4 aVertexPosition;
out vec2 fragCoord;
void main() {
  gl_Position = aVertexPosition;
  fragCoord = aVertexPosition.xy;
}
