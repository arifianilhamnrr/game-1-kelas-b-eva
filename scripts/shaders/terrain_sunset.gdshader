shader_type canvas_item;

uniform vec3 shadow_color : source_color = vec3(0.12, 0.07, 0.25);
uniform vec3 mid_color : source_color = vec3(0.48, 0.22, 0.48);
uniform vec3 light_color : source_color = vec3(1.0, 0.58, 0.30);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float luminance = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	vec3 themed = mix(shadow_color, mid_color, smoothstep(0.05, 0.55, luminance));
	themed = mix(themed, light_color, smoothstep(0.55, 1.0, luminance));

	// Rumput hijau di atlas menjadi highlight emas agar menyatu dengan senja.
	float green_mask = smoothstep(0.04, 0.28, source.g - source.r)
		* smoothstep(0.02, 0.22, source.g - source.b);
	themed = mix(themed, vec3(0.96, 0.58, 0.20) * (0.65 + luminance * 0.55), green_mask);

	// Sedikit warna asli dipertahankan agar detail pixel art tidak hilang.
	themed = mix(themed, source.rgb * vec3(1.08, 0.82, 1.12), 0.18);
	COLOR = vec4(themed, source.a);
}
