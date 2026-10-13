class_name GameHud
extends CanvasLayer

var score: int:
	get: return GameState.score
var fruits: int:
	get: return GameState.fruits

@onready var score_val := find_child("ScoreValue", true, false) as Label
@onready var fruits_val := find_child("FruitsValue", true, false) as Label
@onready var lives_val := find_child("LivesValue", true, false) as Label

func _ready() -> void:
	add_to_group("hud")
	GameState.score_changed.connect(_on_score_changed)
	GameState.fruits_changed.connect(_on_fruits_changed)
	GameState.lives_changed.connect(_on_lives_changed)
	_on_score_changed(GameState.score)
	_on_fruits_changed(GameState.fruits)
	_on_lives_changed(GameState.lives, GameState.max_lives)

func _on_score_changed(value: int) -> void:
	if score_val:
		score_val.text = "%06d" % value
		_pop(score_val)

func _on_fruits_changed(value: int) -> void:
	if fruits_val:
		fruits_val.text = str(value)
		_pop(fruits_val)

func _on_lives_changed(value: int, maximum: int) -> void:
	if lives_val:
		var hearts := ""
		for index in range(maximum):
			hearts += "❤️" if index < value else "🖤"
		lives_val.text = hearts
		_pop(lives_val)

# Compatibility API: objek lama tetap bisa memanggil HUD selama migrasi.
func add_fruit(points: int = 100) -> void:
	GameState.collect_fruit(points)

func add_score(points: int) -> void:
	GameState.add_score(points)

func update_lives(count: int) -> void:
	GameState.set_lives(count)

func reset_game() -> void:
	GameState.reset()

func _pop(node: Control) -> void:
	if not node or not is_node_ready():
		return
	node.pivot_offset = node.size / 2.0
	var tween := create_tween()
	tween.tween_property(node, "scale", Vector2(1.25, 1.25), 0.08)
	tween.tween_property(node, "scale", Vector2.ONE, 0.12)
