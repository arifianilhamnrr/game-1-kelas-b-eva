@tool
class_name MountainParallaxBackground
extends CanvasLayer

const SUN = preload("res://assets/background_custom/sun_pixel.svg")
const MOUNTAIN_FAR = preload("res://assets/background_custom/mountain_small.png")
const MOUNTAIN_MID = preload("res://assets/background_custom/mountain_large_2.png")
const MOUNTAIN_NEAR = preload("res://assets/background_custom/mountain_large_1.png")
const CLOUD_1 = preload("res://assets/background_custom/cloud_1.png")
const CLOUD_2 = preload("res://assets/background_custom/cloud_2.png")

const ARENA_WIDTH := 7552.0
const ARENA_HEIGHT := 720.0

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
	sky.position = Vector2.ZERO
	sky.size = Vector2(ARENA_WIDTH, ARENA_HEIGHT)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sky.material = _make_sky_material()
	_add_generated_child(sky)

func _build_sun() -> void:
	var glow := ColorRect.new()
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.material = _make_sun_glow_material()
	_add_generated_child(glow)
	_add_parallax_sprite(SUN, Vector2(770, 190), Vector2(0.72, 0.72), 0.035)

func _build_clouds() -> void:
	# Awan disebar di seluruh lebar arena agar setiap halaman preview terisi.
	# Hanya dua aset yang dipakai, tetapi ukuran/tinggi/opacity divariasikan.
	var cloud_layout: Array[Dictionary] = [
		{"texture": CLOUD_1, "position": Vector2(170, 145), "scale": 0.105, "ratio": 0.08, "speed": -7.0, "alpha": 0.86},
		{"texture": CLOUD_2, "position": Vector2(650, 255), "scale": 0.072, "ratio": 0.06, "speed": -4.2, "alpha": 0.70},
		{"texture": CLOUD_1, "position": Vector2(1100, 80), "scale": 0.080, "ratio": 0.10, "speed": -5.8, "alpha": 0.76},
		{"texture": CLOUD_2, "position": Vector2(1580, 175), "scale": 0.100, "ratio": 0.07, "speed": -3.8, "alpha": 0.82},
		{"texture": CLOUD_1, "position": Vector2(2080, 285), "scale": 0.067, "ratio": 0.09, "speed": -6.5, "alpha": 0.66},
		{"texture": CLOUD_2, "position": Vector2(2540, 105), "scale": 0.086, "ratio": 0.06, "speed": -4.5, "alpha": 0.78},
		{"texture": CLOUD_1, "position": Vector2(3040, 195), "scale": 0.112, "ratio": 0.08, "speed": -7.2, "alpha": 0.84},
		{"texture": CLOUD_2, "position": Vector2(3540, 310), "scale": 0.064, "ratio": 0.11, "speed": -5.0, "alpha": 0.62},
		{"texture": CLOUD_1, "position": Vector2(4010, 95), "scale": 0.078, "ratio": 0.07, "speed": -6.0, "alpha": 0.74},
		{"texture": CLOUD_2, "position": Vector2(4480, 210), "scale": 0.105, "ratio": 0.09, "speed": -4.0, "alpha": 0.84},
		{"texture": CLOUD_1, "position": Vector2(5000, 300), "scale": 0.068, "ratio": 0.10, "speed": -6.8, "alpha": 0.65},
		{"texture": CLOUD_2, "position": Vector2(5470, 125), "scale": 0.082, "ratio": 0.06, "speed": -4.4, "alpha": 0.76},
		{"texture": CLOUD_1, "position": Vector2(5970, 225), "scale": 0.108, "ratio": 0.08, "speed": -7.0, "alpha": 0.84},
		{"texture": CLOUD_2, "position": Vector2(6470, 75), "scale": 0.070, "ratio": 0.07, "speed": -4.8, "alpha": 0.68},
		{"texture": CLOUD_1, "position": Vector2(6960, 290), "scale": 0.074, "ratio": 0.10, "speed": -6.2, "alpha": 0.70},
		{"texture": CLOUD_2, "position": Vector2(7380, 165), "scale": 0.092, "ratio": 0.06, "speed": -3.7, "alpha": 0.80}
	]
	for cloud in cloud_layout:
		var size := float(cloud.scale)
		_add_moving_cloud(
			cloud.texture as Texture2D,
			cloud.position as Vector2,
			Vector2(size, size),
			float(cloud.ratio),
			float(cloud.speed),
			float(cloud.alpha)
		)

func _add_moving_cloud(texture: Texture2D, base_position: Vector2, sprite_scale: Vector2, ratio: float, speed: float, alpha: float) -> void:
	var sprite := _create_sprite(texture, base_position, sprite_scale, Color(1.0, 0.94, 0.98, alpha))
	layers.append({
		"node": sprite,
		"base": base_position,
		"ratio": ratio,
		"cloud_speed": speed,
		"cloud_offset": 0.0
	})

func _build_mountains() -> void:
	_add_mountain_row(MOUNTAIN_FAR, 500.0, Vector2(0.31, 0.31), 0.10, Color(0.66, 0.60, 0.85, 0.72))
	_add_mountain_row(MOUNTAIN_MID, 525.0, Vector2(0.36, 0.36), 0.18, Color(0.84, 0.72, 0.92, 0.92))
	_add_mountain_row(MOUNTAIN_NEAR, 570.0, Vector2(0.43, 0.43), 0.27)

func _add_mountain_row(texture: Texture2D, y_position: float, sprite_scale: Vector2, ratio: float, tint := Color.WHITE) -> void:
	# Center pertama/terakhir memperhitungkan lebar sprite, sehingga tidak ada
	# gambar yang menjorok ke luar batas arena pada preview editor.
	var visual_width := texture.get_width() * sprite_scale.x
	var spacing := visual_width * 0.76
	var x_position := visual_width * 0.5
	while x_position <= ARENA_WIDTH - visual_width * 0.5:
		_add_parallax_sprite(texture, Vector2(x_position, y_position), sprite_scale, ratio, 0.0, tint)
		x_position += spacing

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
	float wide_glow = 1.0 - smoothstep(0.02, 0.22, distance_from_sun);
	float soft_core = 1.0 - smoothstep(0.0, 0.09, distance_from_sun);
	vec3 glow_color = mix(vec3(1.0, 0.28, 0.05), vec3(1.0, 0.82, 0.28), soft_core);
	float alpha = wide_glow * 0.17 + soft_core * 0.12;
	COLOR = vec4(glow_color * alpha, alpha);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

func _process(delta: float) -> void:
	# Di editor posisi arena penuh dipertahankan supaya preview mudah dirapikan.
	# Animasi wrap hanya dijalankan ketika game dimainkan.
	if Engine.is_editor_hint():
		return
	elapsed += delta
	var camera := get_viewport().get_camera_2d()
	var camera_position := camera.get_screen_center_position() if camera else Vector2.ZERO
	for item in layers:
		var node := item.node as Sprite2D
		var base := item.base as Vector2
		var ratio := float(item.ratio)
		if item.has("cloud_speed"):
			item.cloud_offset = float(item.cloud_offset) + float(item.cloud_speed) * delta
			var screen_x := fposmod(base.x + float(item.cloud_offset), 1800.0) - 360.0
			node.position = Vector2(screen_x, base.y - camera_position.y * ratio * 0.04)
		else:
			var drift := float(item.drift)
			node.position = base - Vector2(camera_position.x * ratio, camera_position.y * ratio * 0.08)
			node.position.x += sin(elapsed * 0.12) * drift
