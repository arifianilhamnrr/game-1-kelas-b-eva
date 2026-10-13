extends AnimatableBody2D

@export var move_distance: float = 120.0
@export var move_speed: float = 1.5
@export var move_axis: Vector2 = Vector2.RIGHT

var start_pos: Vector2
var time: float = 0.0

func _ready() -> void:
	start_pos = position

func _physics_process(delta: float) -> void:
	time += delta * move_speed
	position = start_pos + move_axis * (sin(time) * move_distance)
