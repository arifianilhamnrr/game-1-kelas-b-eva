extends Area2D

@export var bounce_force: float = -620.0
var sprite: AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		for child in get_children():
			if child is AnimatedSprite2D:
				sprite = child
				break
	if sprite:
		sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.bounce(bounce_force)
		if sprite:
			sprite.play("jump")

func _on_animation_finished() -> void:
	if sprite and sprite.animation == "jump":
		sprite.play("idle")
