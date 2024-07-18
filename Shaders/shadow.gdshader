shader_type canvas_item;

uniform vec4 shadow_color: source_color = vec4(1.0);
uniform float shadow_modifier: hint_range(0.0, 1.0) = 1.0;
uniform float shadow_opacity: hint_range(0.0, 1.0) = 1.0;
uniform float blur_size: hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec2 size = vec2(blur_size) / vec2(textureSize(TEXTURE, 0));
    vec4 color = vec4(0.0);
    vec4 sum = vec4(0.0);
    
    for (float x = -1.0; x <= 1.0; x++) {
        for (float y = -1.0; y <= 1.0; y++) {
            vec4 sample = texture(TEXTURE, UV + vec2(x, y) * size);
            sum += sample;
        }
    }
    
    color = sum / 9.0;

    color.rgb = mix(color.rgb, shadow_color.rgb, shadow_modifier);
    color.a *= shadow_opacity;
    COLOR = color;
}
