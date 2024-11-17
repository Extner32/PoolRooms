shader_type spatial;

uniform sampler2D viewport_tex;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO.r = texture(viewport_tex, UV).r;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
