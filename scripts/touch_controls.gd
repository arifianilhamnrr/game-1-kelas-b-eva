extends CanvasLayer

func _ready() -> void:
	get_viewport().size_changed.connect(_reposition)
	_reposition()

func _reposition() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	
	# Left/Right D-Pad on bottom-left
	var btn_left = get_node_or_null("BtnLeft")
	var btn_right = get_node_or_null("BtnRight")
	if btn_left:
		btn_left.position = Vector2(32, vp_size.y - 128)
	if btn_right:
		btn_right.position = Vector2(152, vp_size.y - 128)
		
	# Jump button on bottom-right
	var btn_jump = get_node_or_null("BtnJump")
	if btn_jump:
		btn_jump.position = Vector2(vp_size.x - 128, vp_size.y - 128)
		
	# Restart button on top-right
	var btn_restart = get_node_or_null("BtnRestart")
	if btn_restart:
		btn_restart.position = Vector2(vp_size.x - 84, 18)
