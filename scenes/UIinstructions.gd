extends VBoxContainer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_ui"):
		self.visible = !self.visible