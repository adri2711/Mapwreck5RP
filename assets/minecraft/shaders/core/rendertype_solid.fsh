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
flat in int customID;
in vec3 BPos;
in vec3 CPos;

out vec4 fragColor;

vec3 do_the_lava(vec3 base, vec3 offset) {
    vec3 pos = BPos + offset;
    float cells = SimplexCellular3D(pos * 0.4 - GameTime * vec3(100.0, 200.0, 150.0) + Hermite2D(pos.xz * 0.5) * 0.2);
    float textu = (Hermite3D(pos * 2.5) + 1.0) / 2.0;

    base -= vec3(cells * textu);

    return base;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    
    if(customID == 1) {
        vec3 lava = do_the_lava(fragColor.rgb, vec3(0.0));
        if(BPos.x < 1.5) {
            if(BPos.z < 1.5) {
                float xfade = BPos.x / 1.5;
                float zfade = BPos.z / 1.5;

                vec3 xlava = do_the_lava(fragColor.rgb, vec3(16.0, 0.0, 0.0));
                vec3 zlava = do_the_lava(fragColor.rgb, vec3(0.0, 0.0, 16.0));
                vec3 xzlava = do_the_lava(fragColor.rgb, vec3(16.0, 0.0, 16.0));

                vec3 no_z = mix(xlava, lava, xfade);
                vec3 yesz = mix(xzlava, zlava, xfade);

                lava = mix(yesz, no_z, zfade);
            }
            else lava = mix(do_the_lava(fragColor.rgb, vec3(16.0, 0.0, 0.0)), lava, BPos.x / 1.5);
        } 
        else if(BPos.z < 1.5) lava = mix(do_the_lava(fragColor.rgb, vec3(0.0, 0.0, 16.0)), lava, BPos.z / 1.5);

        lava.rgb += Hermite3D(vec3((BPos + CPos).xz * 0.01, GameTime * 100.0)) * 0.4 + 0.1;

        fragColor.rgb = lava;
    }
}
