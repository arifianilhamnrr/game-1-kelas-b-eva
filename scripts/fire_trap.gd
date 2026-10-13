extends HazardBase

@export var on_duration: float = 2.0
@export var off_duration: float = 2.0
@export var start_delay: float = 0.0

var is_active: bool = false
var timer: float = 0.0
var sprite: AnimatedSprite2D
var col: CollisionShape2D

func _ready() -> void:
	super._ready()
	sprite = get_node_or_null("AnimatedSprite2D")
	col = get_node_or_null("CollisionShape2D")
	timer = -start_delay
	set_active(false)

func _process(delta: float) -> void:
	timer += delta
	if is_active and timer >= on_duration:
		timer = 0.0
		set_active(false)
	elif not is_active and timer >= off_duration:
		timer = 0.0
		set_active(true)

func set_active(active: bool) -> void:
	is_active = active
	if col:
		col.set_deferred("disabled", not active)
	if sprite:
		if active:
			sprite.play("on")
		else:
			sprite.play("off")

func affect(actor: Actor) -> void:
	if is_active:
		super.affect(actor)
