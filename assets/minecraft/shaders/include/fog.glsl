#ifndef GUARD_FOG
#define GUARD_FOG

#moj_import <gpu_noise_lib.glsl>

vec4 red_fog_solid(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor, float fade, vec3 custom_pos, float GameTime) {
    float normal_fog_value = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    vec4 normal_fog = vec4(mix(inColor.rgb, fogColor.rgb, normal_fog_value * fogColor.a), inColor.a);
    if (vertexDistance <= fogStart) normal_fog = inColor;

    float density = 0.01 + SimplexPerlin3D(custom_pos * 0.1 + GameTime * 500.0) * 0.002 + SimplexPerlin3D(custom_pos * 0.7 + GameTime * 700.0) * 0.001;
    float fog_value = 1.0 - 1 / pow(2.71828183, vertexDistance * density);
    vec4 fog = vec4(mix(inColor.rgb, vec3(78, 166, 168) / 255, fog_value), inColor.a);

    return mix(normal_fog, fog, fade);
}

vec4 linear_fog_solid(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor, vec3 custom_pos, float GameTime) {
    float red_area = distance(fogColor, vec4(4, 8, 13, 255) / 255) / 0.012;
    red_area = 1.0 - clamp(red_area, 0.0, 1.0);
    if(red_area > 0.0 && fogStart < 2711.0) return red_fog_solid(inColor, vertexDistance, fogStart, fogEnd, fogColor, red_area, custom_pos, GameTime);

    if (vertexDistance <= fogStart) return inColor;

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

vec4 red_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor, float fade) {
    float normal_fog_value = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    vec4 normal_fog = vec4(mix(inColor.rgb, fogColor.rgb, normal_fog_value * fogColor.a), inColor.a);
    if (vertexDistance <= fogStart) normal_fog = inColor;

    float fog_value = 1.0 - 1 / pow(2.71828183, vertexDistance * 0.01);
    vec4 fog = vec4(mix(inColor.rgb, vec3(78, 166, 168) / 255, fog_value), inColor.a);

    return mix(normal_fog, fog, fade);
}

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    float red_area = distance(fogColor, vec4(4, 8, 13, 255) / 255) / 0.012;
    red_area = 1.0 - clamp(red_area, 0.0, 1.0);
    if(red_area > 0.0 && fogStart < 2711.0) return red_fog(inColor, vertexDistance, fogStart, fogEnd, fogColor, red_area);

    if (vertexDistance <= fogStart) return inColor;

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

float fog_distance(mat4 modelViewMat, vec3 pos, int shape) {
    if (shape == 0) {
        return length((modelViewMat * vec4(pos, 1.0)).xyz);
    } else {
        float distXZ = length((modelViewMat * vec4(pos.x, 0.0, pos.z, 1.0)).xyz);
        float distY = length((modelViewMat * vec4(0.0, pos.y, 0.0, 1.0)).xyz);
        return max(distXZ, distY);
    }
}

#endif