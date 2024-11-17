shader_type spatial;
render_mode cull_disabled;

uniform sampler2D normal_map1 : hint_normal, repeat_enable;
uniform sampler2D normal_map2 : hint_normal, repeat_enable;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable;

uniform float speed = 0.01;
uniform float refraction = 0.1;
uniform float fresnel_strength = 5.0;

uniform vec2 direction1 = vec2(1, 0);
uniform vec2 direction2 = vec2(0, -0.5);
uniform float roughness = 0.2;
uniform float wave_height = 0.2;
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform float uv_scale = 0.01;

varying vec3 pixel_world_pos;


float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	pixel_world_pos = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	float time = TIME * speed;
	
	vec2 world_uv = pixel_world_pos.xz * uv_scale; 
	
	vec3 normal_map = texture(normal_map1, vec2(world_uv.x+time*direction1.x, world_uv.y+time*direction1.y)).rgb;
	normal_map *= texture(normal_map2, vec2(world_uv.x+time*direction2.x, world_uv.y+time*direction2.y)).rgb;
	
	vec2 distorted_uv = vec2(SCREEN_UV.x + normal_map.x *refraction,
							 SCREEN_UV.y + normal_map.y *refraction);
	
	vec3 albedo = clamp(texture(SCREEN_TEXTURE, distorted_uv).rgb, 0.1, 1.0) * color.rgb;
	NORMAL_MAP = normal_map*wave_height;
	ALBEDO.rgb = albedo;
	ROUGHNESS = roughness * fresnel(fresnel_strength, NORMAL, VIEW);
}