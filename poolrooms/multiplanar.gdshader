shader_type spatial;

uniform sampler2D albedo_texture;

varying vec3 pixel_world_pos;

void vertex() {
	pixel_world_pos = (MODEL_MATRIX*vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 right = cross(world_normal, vec3(0, 1, 0));
	vec3 up = cross(world_normal, right);
	
	float dotp = dot(vec3(0, 0, 1), world_normal);
	vec2 uv = vec2(pixel_world_pos.x*dotp, pixel_world_pos.y);
	vec3 albedo = texture(albedo_texture, uv).rgb;
	
	ALBEDO.rgb = albedo;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
