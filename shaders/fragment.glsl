#version 300 es

precision highp float;
in vec2  fragCoord;
out vec4 fragColor;
uniform float t;


void main() {
    if (length(fragCoord) < .25) {
        fragColor  = vec4(fragCoord.x / 2.0 + 0.5, 
                fragCoord.y / 2.0 + 0.5, 
                sin(t * 5. + 7.5) / 2.0 + 0.5, 
                1.0);
    } else {
        fragColor  = vec4(fragCoord.x / 2.0 + 0.5, 
                fragCoord.y / 2.0 + 0.5, 
                sin(t * 5.) / 2.0 + 0.5, 
                1.0);
    }
}
