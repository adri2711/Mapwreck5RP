#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>
#moj_import <misc.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform int FogShape;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;
flat out int customID;
out vec3 BPos;
out vec3 CPos;

float waterNoise(vec2 p) {
    float time = GameTime * 3500;
    float h = 0.0;
    h += 0.35 * sin(dot(vec2( 0.0, 1.0), p) * 0.5 + 5.0 * noise(p * 0.1)+ time * 0.50); 
    h += 0.45 * sin(dot(vec2(-1.4, 0.8), p) * 0.1 + 5.0 * noise(p * 0.5)+ time * 0.45); 
    return h;
}

void main() {
    vec3 pos = Position + ChunkOffset;

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    BPos = Position;
    CPos = ChunkOffset;

    customID = 0;
    int a = int(texture(Sampler0, texCoord0).a * 255);
    if(a == 243) {
        customID = 1;

        float x_dist = min(distance(BPos.z, 0.0), distance(BPos.z, 16.0)) / 8.0;
        float z_dist = min(distance(BPos.x, 0.0), distance(BPos.x, 16.0)) / 8.0;

        float water_noise = waterNoise(BPos.xz);
        water_noise = water_noise * x_dist * z_dist;

        pos.y += water_noise * 0.25 - 0.1;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}
