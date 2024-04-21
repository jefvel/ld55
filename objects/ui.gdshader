shader_type canvas_item;
const vec2[4] points = vec2[](vec2(-1.0, -1.0), vec2(-1.0, 1.0), vec2(1.0, 1.0), vec2(1.0, -1.0));
void vertex() {
	vec2 p = points[VERTEX_ID];
	float a = (TIME * 5.0 + VERTEX.x) * 0.5;
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(vec2(c,s), vec2(-s,c));
	VERTEX.xy += p * sin(a + VERTEX.y + VERTEX.x * 2.0) * 0.2;//m * p * 1.0;

	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	COLOR = col;
	vec4 shadow = texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE * -1.0));
	COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, 1.0),  max(0.0, col.a - shadow.a));
	// COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
