class_name Collectible
extends Area2D

signal collected(collector: Node2D, points: int)

@export var points: int = 100
var _is_collected := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func can_be_collected_by(body: Node2D) -> bool:
	return body is Player

func collect(body: Node2D) -> void:
	if _is_collected:
		return
	_is_collected = true
	collected.emit(body, points)
	GameState.collect_fruit(points)

func _on_body_entered(body: Node2D) -> void:
	if can_be_collected_by(body):
		collect(body)
