shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec4 silhouette_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform bool flash_active = false; // New uniform to indicate flash status

void fragment() {
    if (flash_active) {
        // If flash is active, do not apply the silhouette effect
        COLOR = texture(TEXTURE, UV);
    } else {
        vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
        vec4 sprite_color = texture(TEXTURE, UV);

        if (all(lessThan(abs(sprite_color - screen_color), vec4(0.01)))) {
            COLOR = sprite_color;
        } else {
            COLOR = vec4(silhouette_color.rgb, silhouette_color.a * sprite_color.a);
        }
    }
}
