shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur_radius : hint_range(0.0, 24.0) = 12.0;
uniform float lod_level : hint_range(0.0, 5.0) = 2.4;
uniform vec4 tint_color : source_color = vec4(0.99, 0.975, 0.945, 0.44);
uniform vec4 border_color : source_color = vec4(1.0, 0.99, 0.96, 0.72);
uniform float corner_radius : hint_range(0.0, 64.0) = 24.0;
uniform float border_width : hint_range(0.0, 6.0) = 2.0;

float rounded_box_sdf(vec2 p, vec2 b, float r) {
	vec2 q = abs(p) - b + vec2(r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 uv_deriv = vec2(
		length(vec2(dFdx(UV.x), dFdy(UV.x))),
		length(vec2(dFdx(UV.y), dFdy(UV.y)))
	);
	vec2 rect_size = 1.0 / max(uv_deriv, vec2(0.00001));
	vec2 local_px = (UV - vec2(0.5)) * rect_size;
	vec2 half_size = rect_size * 0.5;
	float r = min(corner_radius, min(half_size.x, half_size.y));

	float dist = rounded_box_sdf(local_px, half_size - vec2(1.0), r);
	float shape_alpha = 1.0 - smoothstep(-1.0, 0.75, dist);

	if (shape_alpha <= 0.001) {
		discard;
	}

	// Flou circulaire multi-anneaux sur la texture d'écran derrière le panneau
	vec2 px_step = SCREEN_PIXEL_SIZE * blur_radius;
	vec4 blur_col = textureLod(screen_texture, SCREEN_UV, lod_level) * 0.16;

	for (int i = 0; i < 6; i++) {
		float angle = float(i) * 1.04719755;
		vec2 offset = vec2(cos(angle), sin(angle)) * px_step * 0.5;
		blur_col += textureLod(screen_texture, SCREEN_UV + offset, lod_level) * 0.07;
	}

	for (int i = 0; i < 12; i++) {
		float angle = float(i) * 0.52359878 + 0.26179939;
		vec2 offset = vec2(cos(angle), sin(angle)) * px_step;
		blur_col += textureLod(screen_texture, SCREEN_UV + offset, lod_level) * 0.035;
	}

	// Léger reflet lumineux verre dépoli vers le haut du panneau
	float sheen = smoothstep(0.65, 0.0, UV.y) * 0.11;
	vec3 glass_rgb = mix(blur_col.rgb, tint_color.rgb, tint_color.a) + vec3(sheen);

	// Bordure lumineuse subtile
	float border_mask = smoothstep(-border_width - 1.0, -border_width, dist) * shape_alpha;
	vec3 final_rgb = mix(glass_rgb, border_color.rgb, border_mask * border_color.a);

	COLOR = vec4(final_rgb, shape_alpha);
}
