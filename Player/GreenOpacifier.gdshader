shader_type canvas_item;

global uniform vec4 OpaqueSlimeColor;
global uniform float SlimeOpaqueness;

void fragment() {
	// Called for every pixel the material is visible on.
	if(texture(TEXTURE, UV) == OpaqueSlimeColor)
	{
		COLOR = texture(TEXTURE, UV);
		COLOR.a *= SlimeOpaqueness;
	}
	else
	{
		COLOR = texture(TEXTURE, UV);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
