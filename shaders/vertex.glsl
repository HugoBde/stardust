#version 450
precision highp float;

in vec3 aVertexPosition;

uniform float t;

uniform mat4 proj;
uniform mat4 view;

out vec2 frag_coord;

#define PI 3.1415926535

void main() {
    gl_Position = proj * view * vec4(aVertexPosition, 1.0);
    frag_coord = aVertexPosition.xy;
}
