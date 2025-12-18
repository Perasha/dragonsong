shader_type canvas_item;

uniform float noise_scale = 0.01;
uniform float time_scale = 0.5;
uniform float wind_strength = 1.0;
uniform vec2 wind_direction = vec2(1.0, 0.0);

uniform vec4 weak_color : source_color = vec4(0.2, 0.3, 1.0, 0.6);
uniform vec4 strong_color : source_color = vec4(1.0, 0.2, 0.2, 0.6);

/*
    2D Perlin-style noise (cheap & smooth)
*/
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
         + (c - a) * u.y * (1.0 - u.x)
         + (d - b) * u.x * u.y;
}

void fragment() {
    // Convert UV (0..1) to world-ish scale
    vec2 pos = UV * (1.0 / noise_scale);

    // Animate noise over time
    float t = TIME * time_scale;

    float n = noise(pos + vec2(t, t)) * 2.0 - 1.0;

    // Wind magnitude visualization
    float strength = abs(n);

    // Color blend based on strength
    vec4 color = mix(weak_color, strong_color, strength);

    // Fade out near edges (soft border)
    float edge_fade = smoothstep(0.0, 0.1, UV.x)
                    * smoothstep(0.0, 0.1, UV.y)
                    * smoothstep(1.0, 0.9, UV.x)
                    * smoothstep(1.0, 0.9, UV.y);

    COLOR = color * edge_fade;
}
