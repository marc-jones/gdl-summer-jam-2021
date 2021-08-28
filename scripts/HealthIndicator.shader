shader_type canvas_item;

uniform sampler2D full_bar;
uniform float current_value : hint_range(0.0, 1.0);

void fragment() {
	float val = 1.0 - current_value;
	if (val < UV.y) {
		if (UV.y < val+(1.0-val)/2.0) {
			COLOR = texture(full_bar, vec2(UV.x, UV.y-val));
		} else {
			COLOR = texture(full_bar, UV);
		}
	} else {
		COLOR = vec4(0)
	}
}
