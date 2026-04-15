extends VBoxContainer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_ui"):
		self.visible = !self.visible


func _ready():
	if OS.has_feature("mobile") || OS.has_feature("web_android") || OS.has_feature("web_ios"):
		visible = false
	else:
		visible = true
		


