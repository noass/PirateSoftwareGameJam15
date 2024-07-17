shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
uniform float intensity : hint_range(0,1) = 1.0;

uniform float noise_amount = 40.0;

vec4 multiply(vec4 base, vec4 blend){
	return base * blend;
}

void fragment()
{
	vec4 bg_color = texture( SCREEN_TEXTURE, SCREEN_UV );
	COLOR.rgb = mix( COLOR, multiply(bg_color,COLOR), intensity ).rgb;
}
