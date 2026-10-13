extends Node

signal score_changed(score: int)
signal fruits_changed(fruits: int)
signal lives_changed(lives: int, maximum: int)
signal game_reset

var score := 0
var fruits := 0
var lives := 3
var max_lives := 3

func add_score(points: int) -> void:
	score += maxi(points, 0)
	score_changed.emit(score)

func collect_fruit(points: int) -> void:
	fruits += 1
	fruits_changed.emit(fruits)
	add_score(points)

func set_lives(value: int, maximum: int = max_lives) -> void:
	max_lives = maximum
	lives = clampi(value, 0, max_lives)
	lives_changed.emit(lives, max_lives)

func reset() -> void:
	score = 0
	fruits = 0
	lives = max_lives
	score_changed.emit(score)
	fruits_changed.emit(fruits)
	lives_changed.emit(lives, max_lives)
	game_reset.emit()
