class_name Actor
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 1
var _health: int

var health: int:
	get:
		return _health

func _ready() -> void:
	_health = max_health

func take_damage(amount: int = 1, bypass_invulnerability: bool = false) -> void:
	if amount <= 0:
		return
	_health = maxi(_health - amount, 0)
	health_changed.emit(_health, max_health)
	if _health == 0:
		died.emit()
		die()

func restore_health() -> void:
	_health = max_health
	health_changed.emit(_health, max_health)

func die() -> void:
	queue_free()
