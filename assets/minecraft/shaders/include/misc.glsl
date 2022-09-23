#ifndef GUARD_MISC
#define GUARD_MISC

const int NUM_OCTAVES = 4;

#moj_import <gpu_noise_lib.glsl>

float waterNoise(vec2 p, float GameTime) {
    float time = GameTime * 3500;
    float h = 0.0;
    h += 0.35 * sin(dot(vec2( 0.0, 1.0), p) * 0.5 + 5.0 * SimplexPerlin2D(p * 0.1)+ time * 0.50); 
    h += 0.45 * sin(dot(vec2(-1.4, 0.8), p) * 0.1 + 5.0 * SimplexPerlin2D(p * 0.5)+ time * 0.45); 
    return h;
}

float hash(float n) {
    return fract(sin(n) * 2711.01);
}

float noise1D(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);

    return mix(hash(i), hash(i + 1.0), u);
}

float hash(vec2 p) {
    return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x))));
}

float noise2D(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float epic_noise(vec2 x) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));

    for(int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise2D(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }

    return v;
}

vec4 fromInt(int n) {
    vec4 r;
    r.r = float(n % 256) / 255.0; n /= 256;
    r.g = float(n % 256) / 255.0; n /= 256;
    r.b = float(n % 256) / 255.0;
    r.a = 1.0;
    return r;
}

vec4 fromTime(float GameTime) {
    int t = int(GameTime * 1200000.0);
    return fromInt(t);
}

#endif
