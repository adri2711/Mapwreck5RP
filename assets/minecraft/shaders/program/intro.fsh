#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D SpriteSampler;
uniform sampler2D CreditSampler;
uniform sampler2D ShiftSampler;
uniform vec2 ScreenSize;
float GameTime;

in vec2 texCoord;
out vec4 fragColor;

vec4 overlay = vec4(0.0);

// Imports don't work on post shaders for some insane reason so I must suffer
float aastep(float threshold, float value, float chaos = 1.0) {
    float afwidth = 0.7 * length(vec2(dFdx(value) * chaos, dFdy(value) * chaos));
    return smoothstep(threshold - afwidth, threshold + afwidth, value);
}

float psrdnoise(vec2 x, vec2 period, float alpha, out vec2 gradient) {

    // Transform to simplex space (axis-aligned hexagonal grid)
    vec2 uv = vec2(x.x + x.y*0.5, x.y);

    // Determine which simplex we're in, with i0 being the "base"
    vec2 i0 = floor(uv);
    vec2 f0 = fract(uv);
    // o1 is the offset in simplex space to the second corner
    float cmp = step(f0.y, f0.x);
    vec2 o1 = vec2(cmp, 1.0-cmp);

    // Enumerate the remaining simplex corners
    vec2 i1 = i0 + o1;
    vec2 i2 = i0 + vec2(1.0, 1.0);

    // Transform corners back to texture space
    vec2 v0 = vec2(i0.x - i0.y * 0.5, i0.y);
    vec2 v1 = vec2(v0.x + o1.x - o1.y * 0.5, v0.y + o1.y);
    vec2 v2 = vec2(v0.x + 0.5, v0.y + 1.0);

    // Compute vectors from v to each of the simplex corners
    vec2 x0 = x - v0;
    vec2 x1 = x - v1;
    vec2 x2 = x - v2;

    vec3 iu, iv;
    vec3 xw, yw;

    // Wrap to periods, if desired
    if(any(greaterThan(period, vec2(0.0)))) {
        xw = vec3(v0.x, v1.x, v2.x);
        yw = vec3(v0.y, v1.y, v2.y);
        if(period.x > 0.0)
            xw = mod(vec3(v0.x, v1.x, v2.x), period.x);
        if(period.y > 0.0)
            yw = mod(vec3(v0.y, v1.y, v2.y), period.y);
        // Transform back to simplex space and fix rounding errors
        iu = floor(xw + 0.5*yw + 0.5);
        iv = floor(yw + 0.5);
    } else { // Shortcut if neither x nor y periods are specified
        iu = vec3(i0.x, i1.x, i2.x);
        iv = vec3(i0.y, i1.y, i2.y);
    }

    // Compute one pseudo-random hash value for each corner
    vec3 hash = mod(iu, 289.0);
    hash = mod((hash*51.0 + 2.0)*hash + iv, 289.0);
    hash = mod((hash*34.0 + 10.0)*hash, 289.0);

    // Pick a pseudo-random angle and add the desired rotation
    vec3 psi = hash * 0.07482 + alpha;
    vec3 gx = cos(psi);
    vec3 gy = sin(psi);

    // Reorganize for dot products below
    vec2 g0 = vec2(gx.x,gy.x);
    vec2 g1 = vec2(gx.y,gy.y);
    vec2 g2 = vec2(gx.z,gy.z);

    // Radial decay with distance from each simplex corner
    vec3 w = 0.8 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2));
    w = max(w, 0.0);
    vec3 w2 = w * w;
    vec3 w4 = w2 * w2;

    // The value of the linear ramp from each of the corners
    vec3 gdotx = vec3(dot(g0, x0), dot(g1, x1), dot(g2, x2));

    // Multiply by the radial decay and sum up the noise value
    float n = dot(w4, gdotx);

    // Compute the first order partial derivatives
    vec3 w3 = w2 * w;
    vec3 dw = -8.0 * w3 * gdotx;
    vec2 dn0 = w4.x * g0 + dw.x * x0;
    vec2 dn1 = w4.y * g1 + dw.y * x1;
    vec2 dn2 = w4.z * g2 + dw.z * x2;
    gradient = 10.9 * (dn0 + dn1 + dn2);

    // Scale the return value to fit nicely into the range [-1,1]
    return 10.9 * n;
}

int fromVec4(vec4 v) {
    return (int(v.b * 255.0) * 256 + int(v.g * 255.0)) * 256 + int(v.r * 255.0);
}

float toTime(vec4 v) {
    return float(fromVec4(v)) / 1000.0;
}

void drawLogo(vec2 offset, float size) {
    vec2 invCoord = vec2(texCoord.x, 1.0 - texCoord.y) - offset;
    vec2 icoord = invCoord * ScreenSize / size;
    if(icoord.x < 0.0 || icoord.y < 0.0 || icoord.x > 886.0 || icoord.y > 335.0) return;

    ivec2 spriteSize = textureSize(SpriteSampler, 0);
    overlay += texture(SpriteSampler, icoord / vec2(spriteSize));
}

void drawCredits(vec2 offset, float size) {
    vec2 invCoord = vec2(texCoord.x, 1.0 - texCoord.y) - offset;
    vec2 icoord = invCoord * ScreenSize / size;
    if(icoord.x < 0.0 || icoord.y < 0.0 || icoord.x > 121.0) return;

    ivec2 spriteSize = textureSize(CreditSampler, 0);
    vec4 data = texture(CreditSampler, icoord / vec2(spriteSize));
    if(data.a == 1.0) overlay = data;
    if(data.g == 1.0 && data.r == 0.0 && data.b == 0.0) {
        vec2 g; 
        vec2 v = vec2(texCoord.x - GameTime / 50.0, texCoord.y - GameTime / 10.0) * 70.0;
        float n = 0.5 + 0.4 * psrdnoise(v, vec2(4.0,4.0), 2.0 * GameTime, g);
        vec2 d = 0.12 * g;
	    n += 0.2 * psrdnoise(2.0 * v + d, 2.0 * vec2(4.0,4.0), 4.1 * GameTime, g);
	    d += 0.06 * g;
	    n += 0.1 * psrdnoise(4.0 * v + d, 4.0 * vec2(4.0,4.0), 8.1 * GameTime, g);
	    d += 0.03 * g;
	    n += 0.05 * psrdnoise(8.0 * v + d , 8.0 * vec2(4.0,4.0), 16.1 * GameTime, g);
        n *= n;
        overlay.rgb = mix(vec3(0.2, 0.0, 0.1), vec3(0.7, 0.0, 0.2), n);
    }
}

void drawShift(vec2 offset, float size) {
    vec2 invCoord = vec2(texCoord.x, 1.0 - texCoord.y) - offset;
    vec2 icoord = invCoord * ScreenSize / size;
    if(icoord.x < 0.0 || icoord.y < 0.0 || icoord.x > 115.0 || icoord.y > 7.0) return;

    ivec2 spriteSize = textureSize(ShiftSampler, 0);
    overlay += texture(ShiftSampler, icoord / vec2(spriteSize));
}

void main() {
    GameTime = toTime(texture(DiffuseSampler, vec2(0.0)));

    fragColor = texture(DiffuseSampler, texCoord);

    vec2 g1;
    float noise = psrdnoise(vec2(texCoord.y * 10.0), vec2(1080.0), GameTime, g1);

    float bg = aastep((texCoord.x * 70.0) - 50.0, noise, 50.0);
    bg = 1.0 - bg;
    if(bg > 0.0) {
        overlay = vec4(0.03, 0.0, 0.06, bg * 0.8 );

        vec2 g2;
        overlay.a += psrdnoise(texCoord * 7.0 + GameTime * 0.3, vec2(1080.0), 0.0, g2) * 0.1;
    }

    drawLogo(vec2(0.07, 0.25), ScreenSize.y / 1080.0);
    drawCredits(vec2(0.8, 1.0 - GameTime / 25.0), ScreenSize.y / 1080.0 * 2.0);
    drawShift(vec2(0.05, 0.7), ScreenSize.y / 1080.0 * 8.0);

    fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a);
}
