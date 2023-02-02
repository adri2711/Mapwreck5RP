#version 150

#moj_import <fog.glsl>
#moj_import <gpu_noise_lib.glsl>
#moj_import <psrdnoise2.glsl>
#moj_import <misc.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;
uniform vec2 ScreenSize;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

flat in int customID;
in vec2 relCoord;
in vec3 graveColor;

out vec4 fragColor;

float aastep(float threshold, float value) {
    float afwidth = 0.7 * length(vec2(dFdx(value), dFdy(value)));
    return smoothstep(threshold - afwidth, threshold + afwidth, value);
}

void main() {
    // Grave
    if(customID == 1) {
        float r = length(relCoord);
	    float theta = atan(relCoord.y, relCoord.x) / 6.2831853;

        const float radius  = 0.6;
        const float spatter = 0.25;
	    const float spokes  = 50.0;
	    const float breakup = 5.0;
        vec2 g;

        float time = GameTime * 1200.0;

	    vec2 v = vec2(r * breakup, theta * spokes);
        float n = 0.5 + 0.5 * psrdnoise(v + 0.2 * time, vec2(0.0, spokes), time, g);
	    float splotch = aastep(radius, r - spatter * n);
        if(splotch >= 1.0) discard;

	    vec4 blood = vec4(graveColor, 0.5) + SimplexPerlin3D(vec3(relCoord * 2.0 + GameTime * 100.0, GameTime * 500.0)) * 0.3;
	    const vec4 background = vec4(0.0);

        fragColor = mix(blood, background, splotch);
        return;
    }
    // Menu time
    if(customID == 2) {
        if(relCoord.x > 1 / ScreenSize.x || relCoord.y > 1 / ScreenSize.y) discard;
        fragColor = fromTime(GameTime);
        return;
    }

    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if(color.a < 0.1) discard;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
