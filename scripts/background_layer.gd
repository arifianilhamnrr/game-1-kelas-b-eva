@tool
class_name MountainParallaxBackground
extends CanvasLayer

const SUN = preload("res://assets/background_custom/sun.png")
const MOUNTAIN_FAR = preload("res://assets/background_custom/mountain_small.png")
const MOUNTAIN_MID = preload("res://assets/background_custom/mountain_large_2.png")
const MOUNTAIN_NEAR = preload("res://assets/background_custom/mountain_large_1.png")
const CLOUD_1 = preload("res://assets/background_custom/cloud_1.png")
const CLOUD_2 = preload("res://assets/background_custom/cloud_2.png")

var layers: Array[Dictionary] = []
var elapsed := 0.0

func _ready() -> void:
	layer = -100
	_clear_generated_preview()
	_build_sky()
	_build_sun()
	_build_clouds()
	_build_mountains()

func _clear_generated_preview() -> void:
	layers.clear()
	for child in get_children():
		if child.has_meta("generated_background"):
			child.queue_free()

func _add_generated_child(node: Node) -> void:
	node.set_meta("generated_background", true)
	add_child(node)

func _build_sky() -> void:
	var sky := ColorRect.new()
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sky.material = _make_sky_material()
	_add_generated_child(sky)

func _build_sun() -> void:
	var glow := ColorRect.new()
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.material = _make_sun_glow_material()
	_add_generated_child(glow)
	_add_parallax_sprite(SUN, Vector2(770, 190), Vector2(0.05, 0.05), 0.035)

func _build_clouds() -> void:
	_add_moving_cloud(CLOUD_1, Vector2(-180, 150), Vector2(0.13, 0.13), 0.08, -7.0)
	_add_moving_cloud(CLOUD_2, Vector2(380, 90), Vector2(0.10, 0.10), 0.06, -4.5)
	_add_moving_cloud(CLOUD_1, Vector2(900, 250), Vector2(0.085, 0.085), 0.10, -6.0)
	_add_moving_cloud(CLOUD_2, Vector2(1320, 175), Vector2(0.075, 0.075), 0.07, -3.5)

func _add_moving_cloud(texture: Texture2D, base_position: Vector2, sprite_scale: Vector2, ratio: float, speed: float) -> void:
	var sprite := _create_sprite(texture, base_position, sprite_scale, Color(1.0, 0.94, 0.98, 0.82))
	layers.append({
		"node": sprite,
		"base": base_position,
		"ratio": ratio,
		"cloud_speed": speed,
		"cloud_offset": 0.0
	})

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
	var sprite := _create_sprite(texture, base_position, sprite_scale, tint)
	layers.append({"node": sprite, "base": base_position, "ratio": ratio, "drift": drift})

func _create_sprite(texture: Texture2D, base_position: Vector2, sprite_scale: Vector2, tint: Color) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = base_position
	sprite.scale = sprite_scale
	sprite.modulate = tint
	_add_generated_child(sprite)
	return sprite

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
		if item.has("cloud_speed"):
			item.cloud_offset = float(item.cloud_offset) + float(item.cloud_speed) * delta
			var screen_x := fposmod(base.x + float(item.cloud_offset), 1600.0) - 260.0
			node.position = Vector2(screen_x, base.y - camera_position.y * ratio * 0.04)
		else:
			var drift := float(item.drift)
			node.position = base - Vector2(camera_position.x * ratio, camera_position.y * ratio * 0.08)
			node.position.x += sin(elapsed * 0.12) * drift
