shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable;
uniform sampler2D normal_map : hint_normal, repeat_enable;
uniform float speed = 0.1;
uniform float scale = 0.1;
uniform float distortion = 0.01;
uniform vec2 direction = vec2(1, 1);
uniform vec3 color : source_color;

void fragment() {
	float time = TIME * speed;
	vec2 offset = texture(normal_map, SCREEN_UV*scale+direction*speed*time).xy * distortion;
	COLOR.rgb = texture(SCREEN_TEXTURE, SCREEN_UV+offset).rgb*color;
}
