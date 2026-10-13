extends HazardBase

@export var move_distance: float = 0.0
@export var move_speed: float = 2.0
@export var move_axis: Vector2 = Vector2.ZERO

var start_pos: Vector2
var time_passed: float = 0.0

func _ready() -> void:
	super._ready()
	start_pos = position

func _process(delta: float) -> void:
	if move_distance > 0.0 and move_axis != Vector2.ZERO:
		time_passed += delta * move_speed
		position = start_pos + move_axis * (sin(time_passed) * move_distance)
