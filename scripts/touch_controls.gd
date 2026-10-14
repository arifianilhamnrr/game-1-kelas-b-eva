@tool
extends CanvasLayer
## Menata tombol kontrol sentuh supaya nyaman dipakai di layar HP.
##
## Ukuran tombol diatur lewat 'scale' (tekstur digambar dari pojok kiri-atas,
## dan area tekan mengikuti transform node, jadi visual & sentuhan sama-sama
## membesar). Posisi dihitung dari ukuran layar supaya jarak tepi konsisten di
## berbagai rasio perangkat.

## Pengali ukuran tombol arah. Tekstur 96 px -> sekitar 139 px.
@export_range(1.0, 2.5, 0.05) var dpad_scale: float = 1.45:
	set(value):
		dpad_scale = value
		_refresh_if_ready()

## Pengali ukuran tombol lompat. Tekstur 96 px -> sekitar 149 px.
@export_range(1.0, 2.5, 0.05) var jump_scale: float = 1.55:
	set(value):
		jump_scale = value
		_refresh_if_ready()

## Pengali ukuran tombol restart. Tekstur 64 px -> sekitar 83 px.
@export_range(1.0, 2.5, 0.05) var restart_scale: float = 1.30:
	set(value):
		restart_scale = value
		_refresh_if_ready()

## Jarak tombol dari tepi layar.
@export_range(0.0, 120.0, 1.0) var screen_margin: float = 30.0:
	set(value):
		screen_margin = value
		_refresh_if_ready()

## Jarak antara tombol kiri dan kanan.
@export_range(0.0, 120.0, 1.0) var dpad_gap: float = 16.0:
	set(value):
		dpad_gap = value
		_refresh_if_ready()

const DPAD_TEXTURE_SIZE := 96.0
const JUMP_TEXTURE_SIZE := 96.0
const RESTART_TEXTURE_SIZE := 64.0

func _ready() -> void:
	get_viewport().size_changed.connect(_reposition)
	_reposition()

func _refresh_if_ready() -> void:
	if is_node_ready():
		_reposition()

func _reposition() -> void:
	var screen := get_viewport().get_visible_rect().size

	var dpad_size := DPAD_TEXTURE_SIZE * dpad_scale
	var jump_size := JUMP_TEXTURE_SIZE * jump_scale
	var restart_size := RESTART_TEXTURE_SIZE * restart_scale

	var bottom := screen.y - screen_margin
	var right := screen.x - screen_margin

	# Tombol arah di kiri bawah.
	var btn_left := get_node_or_null("BtnLeft") as TouchScreenButton
	if btn_left:
		btn_left.scale = Vector2.ONE * dpad_scale
		btn_left.position = Vector2(screen_margin, bottom - dpad_size)

	var btn_right := get_node_or_null("BtnRight") as TouchScreenButton
	if btn_right:
		btn_right.scale = Vector2.ONE * dpad_scale
		btn_right.position = Vector2(screen_margin + dpad_size + dpad_gap, bottom - dpad_size)

	# Tombol lompat di kanan bawah.
	var btn_jump := get_node_or_null("BtnJump") as TouchScreenButton
	if btn_jump:
		btn_jump.scale = Vector2.ONE * jump_scale
		btn_jump.position = Vector2(right - jump_size, bottom - jump_size)

	# Tombol restart di kanan atas.
	var btn_restart := get_node_or_null("BtnRestart") as TouchScreenButton
	if btn_restart:
		btn_restart.scale = Vector2.ONE * restart_scale
		btn_restart.position = Vector2(right - restart_size, screen_margin)
