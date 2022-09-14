shader_type canvas_item;

uniform float amount = 0.0;

vec2 distort(vec2 r, float alpha)
{
    return r * -alpha * (0.5 - dot(r, r));
}

void fragment()
{
	vec2 uv = UV + distort(UV - vec2(0.5), amount);
	COLOR = texture(TEXTURE, uv);
}