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
noperspective out vec3 customPos;

void main() {
    vec3 pos = Position + ChunkOffset;

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    bool water = distance(Color, vec4(1.0)) > 0.05 && distance(Color, vec4(0.8, 0.8, 0.8, 1.0)) > 0.05 && distance(Color, vec4(0.6, 0.6, 0.6, 1.0)) > 0.05 && distance(Color, vec4(0.5, 0.5, 0.5, 1.0)) > 0.05;
    muddy = int(water && distance(Color.rgb, vec3(73,50,8)/255.0) < 0.01 || distance(Color.rgb, vec3(43,30,4)/255.0) < 0.01 || distance(Color.rgb, vec3(58,40,6)/255.0) < 0.01);
    BPos = Position;
    CPos = ChunkOffset;

    if(water) {
        float x_dist = min(distance(BPos.z, 0.0), distance(BPos.z, 16.0)) / 8.0;
        float z_dist = min(distance(BPos.x, 0.0), distance(BPos.x, 16.0)) / 8.0;

        float water_noise = waterNoise(BPos.xz, GameTime);
        water_noise = water_noise * x_dist * z_dist;

        pos.y += water_noise * 0.15;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    customPos = BPos + CPos;
}
