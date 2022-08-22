#version 150

#moj_import <fog.glsl>
#moj_import <misc.glsl>
#moj_import <gpu_noise_lib.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform float GameTime;
uniform vec2 ScreenSize;
uniform mat4 ProjMat;
uniform mat4 ModelViewMat;

in float vertexDistance;

out vec4 fragColor;

const vec3 base_color = vec3(0.8, 0.1, 1.0);
const vec3 h1_color = vec3(1.0, 0.0, 0.8);
const vec3 h2_color = vec3(1.0, 0.7, 0.0);

vec3 warp(vec3 v) {
    vec3 h_color = h1_color * abs(v.x) + h2_color * noise(v.y);

    float base_noise = epic_noise(v.xz * 4.0);
    float base = pow(base_noise * v.y, 2.0);

    float h_noise = epic_noise(v.yz * pow(v.x, 2.0) * 13.0 + v.xy * pow(v.z, 2.0) * 7.0);
    float h = clamp(pow(h_noise, 10.0) * 8.0, 0.0, 1.0);

    return mix(base_color * base, h_color, h);
}

void main() {
    vec4 cast_pos = normalize(inverse(ProjMat) * vec4((gl_FragCoord.xy / ScreenSize - 0.5) * 2.0, 1.0, 1.0));

    vec3 v = normalize(cast_pos.xyz * mat3(ModelViewMat));
    v -= sin(GameTime * 60.0) * vec3((SimplexPerlin3D(v * 2.5) + 1.0) / 2.0) * 0.5;

    fragColor = vec4(warp(v), 1.0);
}
