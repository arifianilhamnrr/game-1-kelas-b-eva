class_name Player
extends Actor

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const DOUBLE_JUMP_VELOCITY := -370.0
const SFX_JUMP = preload("res://assets/Audio/jump.wav")

@export var max_jumps := 2
var jump_count := 0
var jump_held := false
var is_invulnerable := false
var spawn_position: Vector2
var start_position: Vector2
var sprite2d: AnimatedSprite2D
var jump_sfx_player: AudioStreamPlayer

func _ready() -> void:
	max_health = 3
	super._ready()
	add_to_group("player")
	start_position = global_position
	spawn_position = global_position
	sprite2d = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	jump_sfx_player = AudioStreamPlayer.new()
	jump_sfx_player.stream = SFX_JUMP
	jump_sfx_player.volume_db = -4.0
	add_child(jump_sfx_player)
	GameState.set_lives(health, max_health)

func take_damage(amount: int = 1, bypass_invulnerability: bool = false) -> void:
	if is_invulnerable and not bypass_invulnerability:
		return
	_health = maxi(_health - amount, 0)
	health_changed.emit(_health, max_health)
	GameState.set_lives(_health, max_health)
	if _health == 0:
		died.emit()
		die()
	else:
		respawn()
		_start_invulnerability()

func die() -> void:
	spawn_position = start_position
	restore_health()
	GameState.reset()
	respawn()
	_start_invulnerability()

func hit_by_enemy() -> void:
	take_damage()

func fall_damage() -> void:
	take_damage(1, true)

func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	jump_count = 0
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.reset_smoothing()

func _start_invulnerability(duration := 1.5) -> void:
	is_invulnerable = true
	if not sprite2d:
		is_invulnerable = false
		return
	var tween := create_tween()
	for _index in range(5):
		tween.tween_property(sprite2d, "modulate:a", 0.3, duration / 10.0)
		tween.tween_property(sprite2d, "modulate:a", 1.0, duration / 10.0)
	tween.tween_callback(func() -> void: is_invulnerable = false)

func bounce(force := -620.0) -> void:
	velocity.y = force
	jump_count = 1
	_play_animation(&"Jump")

func _jump_just_pressed() -> bool:
	var pressed := Input.is_action_pressed("ui_accept") \
		or Input.is_action_pressed("ui_up") \
		or Input.is_physical_key_pressed(KEY_W)
	if pressed and not jump_held:
		jump_held = true
		return true
	if not pressed:
		jump_held = false
	return false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif velocity.y >= 0.0:
		jump_count = 0
	if _jump_just_pressed():
		if is_on_floor():
			_jump(JUMP_VELOCITY, &"Jump", 1.0)
		elif jump_count < max_jumps:
			_jump(DOUBLE_JUMP_VELOCITY, &"Double Jump", 1.25)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction == 0.0:
		if Input.is_physical_key_pressed(KEY_A):
			direction -= 1.0
		if Input.is_physical_key_pressed(KEY_D):
			direction += 1.0
	velocity.x = direction * SPEED if direction != 0.0 else move_toward(velocity.x, 0.0, SPEED)
	if sprite2d and direction != 0.0:
		sprite2d.flip_h = direction < 0.0
	move_and_slide()
	_update_animation()
	if global_position.y > 750.0:
		fall_damage()
	elif Input.is_action_just_pressed("Respawn"):
		take_damage()

func _jump(force: float, animation: StringName, pitch: float) -> void:
	velocity.y = force
	jump_count += 1
	_play_animation(animation)
	jump_sfx_player.pitch_scale = pitch
	jump_sfx_player.play()

func _update_animation() -> void:
	if not sprite2d:
		return
	if not is_on_floor():
		if sprite2d.animation != &"Double Jump" or not sprite2d.is_playing():
			_play_animation(&"Jump")
	elif absf(velocity.x) > 1.0:
		_play_animation(&"Run")
	else:
		_play_animation(&"Idle")

func _play_animation(animation: StringName) -> void:
	if sprite2d and sprite2d.sprite_frames.has_animation(animation):
		sprite2d.play(animation)
