shader_type canvas_item;

uniform vec4 line_color : hint_color = vec4(1.0);
uniform float line_thickness : hint_range(0.0, 10.0) = 0.0;

uniform vec4 fill_color: hint_color = vec4(1.0);
uniform float color_mix: hint_range(0.0, 1.0, 0.01) = 0.0;

uniform float top_skew: hint_range(-5.0, 5.0, 0.01) = 0.0;
uniform float squash = 1.0;

vec4 outline(vec4 color, vec2 pixel_size, sampler2D sample, vec2 uv) {
	vec2 size = pixel_size * line_thickness;

	float outline = texture(sample, uv + vec2(-size.x, 0)).a;
	outline += texture(sample, uv + vec2(0, size.y)).a;
	outline += texture(sample, uv + vec2(size.x, 0)).a;
	outline += texture(sample, uv + vec2(0, -size.y)).a;
	outline += texture(sample, uv + vec2(-size.x, size.y)).a;
	outline += texture(sample, uv + vec2(size.x, size.y)).a;
	outline += texture(sample, uv + vec2(-size.x, -size.y)).a;
	outline += texture(sample, uv + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);

	return mix(color, line_color, outline - color.a);
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
	vec4 color = texture(TEXTURE, UV);
	if (line_thickness > 0.0) {
		color = outline(color, TEXTURE_PIXEL_SIZE, TEXTURE, UV);
	}
	
	COLOR = vec4(((color * (1.0 - color_mix)) + (fill_color * color_mix)).rgb, color.a);
}