class_name PatrolEnemy
extends Actor

const SFX_STOMP = preload("res://assets/Audio/stomp.wav")

@export var speed: float = 65.0
@export var patrol_distance: float = 80.0

var start_x: float = 0.0
var direction: int = 1
var is_dead: bool = false
var turn_cooldown: float = 0.0

var sprite: AnimatedSprite2D
var hitbox: Area2D

func _ready() -> void:
	max_health = 1
	super._ready()
	start_x = position.x
	add_to_group("enemy")
	
	# Only collide with terrain (layer 1), do not rigidly block player body
	collision_layer = 2
	collision_mask = 1
	
	sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		for child in get_children():
			if child is AnimatedSprite2D:
				sprite = child
				break
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("run"):
		sprite.play("run")
		
	hitbox = get_node_or_null("Hitbox")
	if hitbox:
		hitbox.collision_layer = 2
		hitbox.collision_mask = 1 # Detect player (layer 1)
		if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
			hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Debounce turning so enemy never gets stuck on walls
	if turn_cooldown > 0.0:
		turn_cooldown -= delta
	else:
		if is_on_wall():
			direction = -direction
			turn_cooldown = 0.35
		elif abs(position.x - start_x) >= patrol_distance:
			direction = -1 if position.x > start_x else 1
			turn_cooldown = 0.2
		
	velocity.x = direction * speed
	if sprite:
		sprite.flip_h = direction < 0
		
	move_and_slide()

func _play_stomp_sfx() -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = SFX_STOMP
	sfx.volume_db = -1.0
	var parent_node: Node = get_tree().current_scene
	if parent_node == null:
		parent_node = get_parent()
	if parent_node:
		parent_node.add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
		
	# Stomp check: player is touching from above
	# When on top, player.global_position.y is at least 15-40px above enemy.global_position.y
	if body.global_position.y < global_position.y - 4.0:
		# STOMP SUCCESSFUL!
		is_dead = true
		velocity = Vector2.ZERO
		if hitbox:
			hitbox.set_deferred("monitoring", false)
			hitbox.set_deferred("monitorable", false)
		body.bounce(-520.0)
		GameState.add_score(200)
		_play_stomp_sfx()
		if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("hit"):
			sprite.play("hit")
		var tween = create_tween()
		tween.tween_property(self, "scale:y", 0.15, 0.12)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
		tween.tween_callback(queue_free)
	else:
		# Side or bottom touch -> damage player
		if body is Actor:
			body.take_damage(1)
