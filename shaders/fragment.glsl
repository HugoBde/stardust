#version 300 es

precision highp float;
in vec2 fragCoord;
out vec4 fragColor;
uniform float t;
uniform vec2 mouseCoord;

int quantize_steps = 2;

float quantize(float f) {
    f = ceil(f * float(quantize_steps));
    return f / float(quantize_steps);
}

vec3 quantize(vec3 v) {
    return vec3(quantize(v.x), quantize(v.y), quantize(v.z));
}

float positive_sin(float f) {
    return sin(f) / 2.0 + 0.5;
}

float positive_cos(float f) {
    return cos(f) / 2.0 + 0.5;
}

mat4 thresh_map_4 = (1. / 16.) * mat4(0., 12., 3., 15., 8., 4., 11., 7., 2., 14., 1., 13., 10., 6., 9., 5.) - 0.5;

vec3 ordered_dither_4(vec3 c) {
    int x = int(gl_FragCoord.x) % 4;
    int y = int(gl_FragCoord.y) % 4;

    return c + (thresh_map_4[x][y]) / float(quantize_steps);
}

void main() {
    float r = positive_sin(0. + t + length(fragCoord));
    float g = positive_sin(1. + t + length(fragCoord));
    float b = positive_sin(2.5 + t + length(fragCoord));
    vec3 c = vec3(r, g, b);

    if (mouseCoord.x > gl_FragCoord.x) {
        fragColor = vec4(c, 1.0);
    }
    else {
        if (mouseCoord.y > gl_FragCoord.y) {
            fragColor = vec4(quantize(ordered_dither_4(c)), 1.0);
        } else {
            fragColor = vec4(quantize(c), 1.0);
        }
    }
}
