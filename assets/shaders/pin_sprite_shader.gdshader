shader_type canvas_item;

uniform vec4 fill_color: hint_color = vec4(1.0);
uniform float color_mix: hint_range(0.0, 1.0, 0.01) = 0.0;

uniform float top_skew: hint_range(-5.0, 5.0, 0.01) = 0.0;
uniform float squash = 1.0;

uniform sampler2D uv_offset_texture: hint_black;
uniform float offset_amount = 300.0;
uniform float update_sec = .4;


vec2 wobble_offset(sampler2D image, vec2 uv, float time) {
    vec2 offset = texture(uv_offset_texture, uv + floor(time / update_sec) * update_sec).xy * 2.0 - 1.0;
    offset *= 1.0 / offset_amount;
	return offset;
}

vec4 wobble(sampler2D image, vec2 uv, vec2 offset) {
	vec4 offset_color = texture(image, uv + offset);
	vec4 color = texture(image, uv);
	if (offset_color.a < 0.001) {
		offset_color.rgb = color.rgb;
	}
	
    return vec4(offset_color.rgb, color.a);
}

float lerp(float start, float end, float weight) {
	return start + (end - start) * weight;
}

void vertex() {
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 v = VERTEX.xy;
	vec2 vn = v / texture_size;
	float remap_y = lerp(1.0, squash, vn.y);
	VERTEX.y = remap_y * v.y + (1.0 - squash) * texture_size.y;
	
	float remap_x = lerp(top_skew, 0.0, vn.y);
	VERTEX.x = v.x + texture_size.x * remap_x;
}

void fragment() {
	vec2 offset = wobble_offset(TEXTURE, UV, TIME);
	vec4 color = wobble(TEXTURE, UV, offset);
	COLOR = vec4(((color * (1.0 - color_mix)) + (fill_color * color_mix)).rgb, color.a);
}