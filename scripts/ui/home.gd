class_name HomeScreen
extends Control

const LEVEL_SCENE := "res://node_2d.tscn"

@onready var start_button: Button = %StartButton

func _ready() -> void:
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file(LEVEL_SCENE)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
