extends HazardBase

@export var stomp_distance: float = 90.0
@export var fall_speed: float = 300.0
@export var return_speed: float = 60.0
@export var wait_time: float = 1.0

var start_y: float = 0.0
enum State { IDLE, FALLING, WAITING, RETURNING }
var state: State = State.IDLE
var wait_timer: float = 0.0

func _ready() -> void:
	super._ready()
	start_y = position.y

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			wait_timer += delta
			if wait_timer >= 1.5:
				wait_timer = 0.0
				state = State.FALLING
		State.FALLING:
			position.y += fall_speed * delta
			if position.y >= start_y + stomp_distance:
				position.y = start_y + stomp_distance
				state = State.WAITING
		State.WAITING:
			wait_timer += delta
			if wait_timer >= wait_time:
				wait_timer = 0.0
				state = State.RETURNING
		State.RETURNING:
			position.y = move_toward(position.y, start_y, return_speed * delta)
			if is_equal_approx(position.y, start_y):
				state = State.IDLE
