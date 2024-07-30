shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 0.5;
uniform vec4 bg_color: source_color;
uniform vec4 wave_1_color: source_color;
uniform vec4 wave_2_color: source_color;
uniform float wave_1_speed = -1.0;
uniform float wave_2_speed = 1.0;
uniform float wave_amplitude = 0.1; // New uniform for wave amplitude
uniform float bg_opacity: hint_range(0.0, 1.0) = 1.0; // New uniform for background opacity

vec4 wave(vec2 uv, vec4 wave_color, float level, float freq, float amp, float sin_shift, float speed) {
    float sinus = sin((uv.x + sin_shift + TIME * speed) * freq) * amp;
    float shifted_level = (1.0 + 2.0 * amp) * level - amp; // Shift to completely hide or fill
    float treshold = step(1.0 - sinus - shifted_level, uv.y);
    return wave_color * treshold;
}

void fragment() {
    vec4 wave1 = wave(UV, wave_1_color, progress, 2.5, wave_amplitude, 0.0, wave_1_speed); // Use wave_amplitude
    vec4 wave2 = wave(UV, wave_2_color, progress, 2.0, wave_amplitude, 0.7785 * TIME, wave_2_speed); // Use wave_amplitude
    
    vec4 combined_waves = mix(wave1, wave2, wave2.a);
    vec4 bg_color_with_opacity = vec4(bg_color.rgb, bg_opacity); // Set background opacity
    COLOR = mix(bg_color_with_opacity, combined_waves, combined_waves.a);
}
