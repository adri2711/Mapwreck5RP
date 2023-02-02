#version 150

#moj_import <fog.glsl>
#moj_import <psrdnoise2.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

flat in int customID;
in vec2 relCoord;

out vec4 fragColor;

void main() {
    if(customID == 2) discard;

    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    if(customID == 1) {
        float progress = 0.9 - vertexColor.a * 1.3 + 0.3;
        float time = GameTime * 1200.0;
        float wobble = sin(time) * 0.05;
        float radius = clamp(progress + wobble, 0.0, 1.55);

        vec2 g1;
        float noise = psrdnoise(relCoord * 5.0, vec2(4.0), 0.0, g1) * 0.07;
        vec2 distortion = relCoord + noise;

        if(length(distortion) < radius) discard;
        else {
            vec3 col = vec3(0.1098039, 0.0, 0.2470588);
            vec2 g2;
            col -= (psrdnoise(time * 0.1 + relCoord, vec2(40.0), 0.0, g2) + 1.0) / 2.0 * 0.7;
            fragColor = vec4(col, 1.0);
        }

        return;
    }
    
    if (color.a < 0.1) discard;
}
