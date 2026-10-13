class_name Fruit
extends Collectible

const SFX_FRUIT = preload("res://assets/Audio/fruit.wav")

var sprite: AnimatedSprite2D

func _ready() -> void:
	super._ready()
	sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		for child in get_children():
			if child is AnimatedSprite2D:
				sprite = child
				break

func _play_fruit_sfx() -> void:
	var sfx = AudioStreamPlayer.new()
	sfx.stream = SFX_FRUIT
	sfx.volume_db = -3.0
	var parent_node: Node = get_tree().current_scene
	if parent_node == null:
		parent_node = get_parent()
	if parent_node:
		parent_node.add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

func collect(body: Node2D) -> void:
	if _is_collected:
		return
	super.collect(body)
	_play_fruit_sfx()
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("collected"):
		sprite.play("collected")
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 14.0, 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
