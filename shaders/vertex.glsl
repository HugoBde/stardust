#version 450 
precision highp float;

in vec3 aVertexPosition;

uniform float t;

out vec2 frag_coord;

#define PI 3.1415926535

void main() {
  // gl_Position = projection * view * model * vec4(aVertexPosition, 1.0);
    float shitter = 1/tan(PI/4);
    mat4 proj = transpose(mat4(
                shitter, 0.0, 0.0, 0.0,
                0.0, shitter, 0.0, 0.0,
                0.0, 0.0, -1.0, - 0.0,
                0.0, 0.0, -1.0, 0.0
                ));

  mat4 view = transpose(mat4(
          1.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, t * -2.0,
          0.0, 0.0, 1.0, t * -3.0,
          0.0, 0.0, 0.0, 1.0
          ) * mat4(
              1.0, 0.0, 0.0, 0.0,
              0.0, cos(t * PI/8), -sin(t * PI/8), 0.0,
              0.0, sin(t * PI/8), cos(t * PI/8), 0.0,
              0.0, 0.0, 0.0, 1.0
              ));

  gl_Position = proj * view * vec4(aVertexPosition, 1.0);
  frag_coord = aVertexPosition.xy;
}
