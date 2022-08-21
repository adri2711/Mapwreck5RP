#version 150

#moj_import <fog.glsl>
#moj_import <misc.glsl>
#moj_import <gpu_noise_lib.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;
flat in int muddy;
in vec3 BPos;
in vec3 CPos;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    if(bool(muddy)) {
        float noise1 = Perlin3D(BPos *  5.0 + vec3(0.0, GameTime * 500.0, 0.0));
        float noise2 = Perlin3D(BPos * 10.0 + vec3(0.0, GameTime * 250.0, 0.0));
        float noise3 = PolkaDot3D(BPos + vec3(0.0, GameTime * 250.0, 0.0), 0.01, 0.3);

        fragColor.rgb *= noise1 + noise2;
        fragColor.a += abs(noise1 + noise2) * 0.2;
        fragColor.r = pow(fragColor.r, (abs(noise2) + 0.7));
        fragColor.r += noise3;

        float horizontal_distance = length((BPos + CPos).xz);
        fragColor.a = mix(0.1, fragColor.a, clamp(horizontal_distance / 5.0, 0.0, 1.0));
        fragColor += clamp(1.0 - vertexDistance / 2.0, 0.0, 1.0) * vec4(0.5, 0.0, 0.0, 0.5);
    }
}
