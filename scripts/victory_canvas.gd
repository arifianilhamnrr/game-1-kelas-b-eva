class_name EndGameScreen
extends CanvasLayer

const HOME_SCENE := "res://scenes/home.tscn"
const LEVEL_SCENE := "res://node_2d.tscn"

@onready var overlay := find_child("EndOverlay", true, false) as ColorRect
@onready var panel := find_child("PanelContainer", true, false) as Control
@onready var score_label := find_child("FinalScoreLabel", true, false) as Label
@onready var restart_button := find_child("RestartButton", true, false) as Button

func _ready() -> void:
	if overlay:
		overlay.visible = false

func show_victory() -> void:
	if not overlay or not panel:
		return
	get_tree().paused = true
	overlay.visible = true
	if score_label:
		score_label.text = "SKOR: %06d\nBUAH: %d" % [GameState.score, GameState.fruits]
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.78, 0.78)
	panel.pivot_offset = panel.size / 2.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	restart_button.grab_focus()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	GameState.reset()
	get_tree().change_scene_to_file(LEVEL_SCENE)

func _on_home_button_pressed() -> void:
	get_tree().paused = false
	GameState.reset()
	get_tree().change_scene_to_file(HOME_SCENE)
