shader_type canvas_item;

uniform float amount = 0.0;
uniform vec4 line_color : hint_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;

vec2 distort(vec2 r, float alpha)
{
    return r * -alpha * (0.5 - dot(r, r));
}

vec4 _outline(vec2 pixel_size, sampler2D sampler, vec2 uv) {
	if (line_thickness < 0.1) {
		return texture(sampler, uv);
	}
	
	vec2 size = pixel_size * line_thickness;
	
	float outline = texture(sampler, uv + vec2(-size.x, 0)).a;
	outline += texture(sampler, uv + vec2(0, size.y)).a;
	
	outline += texture(sampler, uv + vec2(size.x, 0)).a;
	
	outline += texture(sampler, uv + vec2(0, -size.y)).a;
	
	
	outline += texture(sampler, uv + vec2(-size.x, size.y)).a;
	
	outline += texture(sampler, uv + vec2(-size.x, size.y * 0.5)).a;
	
	outline += texture(sampler, uv + vec2(size.x, size.y)).a;
	outline += texture(sampler, uv + vec2(size.x, size.y * 0.5)).a;
	
	
	outline += texture(sampler, uv + vec2(-size.x, -size.y)).a;
	outline += texture(sampler, uv + vec2(-size.x, -size.y * 0.5)).a;
	
	outline += texture(sampler, uv + vec2(size.x, -size.y)).a;
	outline += texture(sampler, uv + vec2(size.x, -size.y * 0.5)).a;
	
	
	outline = min(outline, 1.0);
	
	
	vec4 color = texture(sampler, uv);
	return mix(color, line_color, outline - color.a);
}

void fragment()
{
	vec2 uv = UV;
	
	uv = uv + distort(uv - vec2(0.5), amount);
	
	vec4 color = _outline(TEXTURE_PIXEL_SIZE, TEXTURE, uv);
	
	COLOR = color;//texture(TEXTURE, uv);
}