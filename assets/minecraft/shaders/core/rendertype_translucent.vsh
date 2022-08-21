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
flat out int muddy;
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
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    bool water = distance(Color, vec4(1.0)) > 0.05 && distance(Color, vec4(0.8, 0.8, 0.8, 1.0)) > 0.05 && distance(Color, vec4(0.6, 0.6, 0.6, 1.0)) > 0.05;
    muddy = int(water && distance(Color.rgb, vec3(73,50,8)/255.0) < 0.01 || distance(Color.rgb, vec3(43,30,4)/255.0) < 0.01 || distance(Color.rgb, vec3(58,40,6)/255.0) < 0.01);
    BPos = Position;
    CPos = ChunkOffset;

    if(water) {
        float x_dist = min(distance(BPos.z, 0.0), distance(BPos.z, 16.0)) / 8.0;
        float z_dist = min(distance(BPos.x, 0.0), distance(BPos.x, 16.0)) / 8.0;

        float water_noise = waterNoise(BPos.xz);
        water_noise = water_noise * x_dist * z_dist;

        gl_Position.y += water_noise * 0.15;
    }
}
