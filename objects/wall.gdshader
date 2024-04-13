shader_type canvas_item;

uniform vec2 offset;

void vertex() {
	// Called for every vertex the material is visible on.
}



void fragment() { 
	vec2 pos = UV; 
	pos += offset * TEXTURE_PIXEL_SIZE;
	COLOR = texture(TEXTURE, pos); 
}
	// Called for every pixel the material is visible on.


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
