class_name MountainParallaxBackground
extends CanvasLayer

const SUN = preload("res://assets/background_custom/sun.png")
const MOUNTAIN_FAR = preload("res://assets/background_custom/mountain_small.png")
const MOUNTAIN_MID = preload("res://assets/background_custom/mountain_large_2.png")
const MOUNTAIN_NEAR = preload("res://assets/background_custom/mountain_large_1.png")
const CLOUD_1 = preload("res://assets/background_custom/cloud_1.png")
const CLOUD_2 = preload("res://assets/background_custom/cloud_2.png")
const CLOUD_3 = preload("res://assets/background_custom/cloud_3.png")

var layers: Array[Dictionary] = []
var elapsed := 0.0

func _ready() -> void:
	layer = -100
	var legacy := get_node_or_null("TextureRect")
	if legacy:
		legacy.queue_free()
	_build_sky()
	_build_sun()
	_build_clouds()
	_build_mountains()

func _build_sky() -> void:
	var sky := ColorRect.new()
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sky.material = _make_sky_material()
	add_child(sky)

func _build_sun() -> void:
	var glow := ColorRect.new()
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.material = _make_sun_glow_material()
	add_child(glow)
	_add_parallax_sprite(SUN, Vector2(770, 190), Vector2(0.12, 0.12), 0.035)

func _build_clouds() -> void:
	_add_parallax_sprite(CLOUD_1, Vector2(170, 150), Vector2(0.13, 0.13), 0.08, 3.0)
	_add_parallax_sprite(CLOUD_2, Vector2(600, 105), Vector2(0.10, 0.10), 0.06, -2.0)
	_add_parallax_sprite(CLOUD_3, Vector2(970, 260), Vector2(0.09, 0.09), 0.10, 4.0)

func _build_mountains() -> void:
	_add_repeating_sprite(MOUNTAIN_FAR, Vector2(260, 485), Vector2(0.31, 0.31), 0.10, Color(0.66, 0.60, 0.85, 0.72))
	_add_repeating_sprite(MOUNTAIN_MID, Vector2(760, 490), Vector2(0.36, 0.36), 0.18, Color(0.84, 0.72, 0.92, 0.92))
	_add_repeating_sprite(MOUNTAIN_NEAR, Vector2(330, 550), Vector2(0.43, 0.43), 0.27)
	_add_repeating_sprite(MOUNTAIN_NEAR, Vector2(1030, 570), Vector2(0.46, 0.46), 0.31)

func _add_repeating_sprite(texture: Texture2D, base_position: Vector2, sprite_scale: Vector2, ratio: float, tint := Color.WHITE) -> void:
	# Beberapa salinan menjaga pegunungan tetap memenuhi layar sepanjang level.
	for index in range(-1, 5):
		_add_parallax_sprite(texture, base_position + Vector2(index * 1400.0, 0.0), sprite_scale, ratio, 0.0, tint)

func _add_parallax_sprite(texture: Texture2D, base_position: Vector2, sprite_scale: Vector2, ratio: float, drift := 0.0, tint := Color.WHITE) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = base_position
	sprite.scale = sprite_scale
	sprite.modulate = tint
	add_child(sprite)
	layers.append({"node": sprite, "base": base_position, "ratio": ratio, "drift": drift})

func _make_sky_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	float y = UV.y;
	vec3 zenith = vec3(0.24, 0.16, 0.48);
	vec3 violet = vec3(0.52, 0.36, 0.70);
	vec3 peach = vec3(0.96, 0.48, 0.34);
	vec3 dusk = vec3(0.38, 0.16, 0.38);
	vec3 color = mix(zenith, violet, smoothstep(0.0, 0.44, y));
	color = mix(color, peach, smoothstep(0.30, 0.72, y));
	color = mix(color, dusk, smoothstep(0.72, 1.0, y));
	COLOR = vec4(color, 1.0);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _make_sun_glow_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode blend_add;
void fragment() {
	vec2 center = vec2(0.713, 0.264);
	vec2 aspect_uv = vec2((UV.x - center.x) * 1.5, UV.y - center.y);
	float distance_from_sun = length(aspect_uv);
	float wide_glow = 1.0 - smoothstep(0.03, 0.34, distance_from_sun);
	float soft_core = 1.0 - smoothstep(0.0, 0.14, distance_from_sun);
	vec3 glow_color = mix(vec3(1.0, 0.28, 0.05), vec3(1.0, 0.82, 0.28), soft_core);
	float alpha = wide_glow * 0.22 + soft_core * 0.15;
	COLOR = vec4(glow_color * alpha, alpha);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _process(delta: float) -> void:
	elapsed += delta
	var camera := get_viewport().get_camera_2d()
	var camera_position := camera.get_screen_center_position() if camera else Vector2.ZERO
	for item in layers:
		var node := item.node as Sprite2D
		var base := item.base as Vector2
		var ratio := float(item.ratio)
		var drift := float(item.drift)
		node.position = base - Vector2(camera_position.x * ratio, camera_position.y * ratio * 0.08)
		node.position.x += sin(elapsed * 0.12) * drift
