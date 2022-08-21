const int NUM_OCTAVES = 4;

float hash(float n) {
    return fract(sin(n) * 2711.01);
}

float hash(vec2 p) {
    return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x))));
}

float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);

    return mix(hash(i), hash(i + 1.0), u);
}

float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float pnoise(vec3 o) {
    vec3 p = floor(o);
    vec3 fr = fract(o);
        
    float n = p.x + p.y * 57.0 + p.z * 1009.0;

    float a = hash(n +    0.0);
    float b = hash(n +    1.0);
    float c = hash(n +   57.0);
    float d = hash(n +   58.0);
    float e = hash(n + 1009.0);
    float f = hash(n + 1010.0);
    float g = hash(n + 1066.0);
    float h = hash(n + 1067.0);
    
    vec3 t = fr * fr * (3.0 - 2.0 * fr);

    float res1 = a + (b - a) * t.x + (c - a) * t.y + (a - b + d - c) * t.x * t.y;
    float res2 = e + (f - e) * t.x + (g - e) * t.y + (e - f + h - g) * t.x * t.y;
    
    return mix(res1, res2, t.z);
}

float epic_noise(vec2 x) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));

    for(int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }

    return v;
}