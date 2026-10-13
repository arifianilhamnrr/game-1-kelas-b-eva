class_name HazardBase
extends Area2D

@export var damage: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func affect(actor: Actor) -> void:
	actor.take_damage(damage)

func _on_body_entered(body: Node2D) -> void:
	if body is Actor:
		affect(body)
