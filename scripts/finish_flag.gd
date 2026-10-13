extends Area2D

var finished: bool = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if finished:
		return
	if body is Player:
		finished = true
		var root = get_tree().current_scene
		if root and root.has_node("VictoryCanvas"):
			root.get_node("VictoryCanvas").show_victory()
