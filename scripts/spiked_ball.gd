extends Node2D

@export var swing_angle: float = 55.0
@export var swing_speed: float = 2.2
var time: float = 0.0

var arm: Node2D

func _ready() -> void:
	arm = get_node_or_null("Arm")
	var ball_area := get_node_or_null("Arm/BallArea") as Area2D
	if ball_area:
		ball_area.body_entered.connect(_on_hazard_body_entered)

func _physics_process(delta: float) -> void:
	if arm:
		time += delta * swing_speed
		arm.rotation_degrees = sin(time) * swing_angle

func _on_hazard_body_entered(body: Node2D) -> void:
	if body is Actor:
		body.take_damage(1)
