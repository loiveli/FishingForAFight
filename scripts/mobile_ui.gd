extends Control

@export var move_up_btn: Button
@export var move_down_btn: Button
@export var move_left_btn: Button
@export var move_right_btn: Button
@export var scan_btn: Button
@export var magnet_btn: Button

func _ready() -> void:
	if OS.has_feature("mobile") || OS.has_feature("web_android") || OS.has_feature("web_ios"):
		visible = true
	else:
		queue_free()
		return

	var bindings = {
		move_up_btn:    "move_forward",
		move_down_btn:  "move_back",
		move_left_btn:  "move_left",
		move_right_btn: "move_right",
		scan_btn:       "scan_loot",
		magnet_btn:     "magnet_toggle",
	}

	for btn in bindings:
		if btn == null:
			continue
		var action = bindings[btn]
		btn.button_down.connect(_fire_action.bind(action, true))
		btn.button_up.connect(_fire_action.bind(action, false))

func _fire_action(action: String, pressed: bool) -> void:
	var event = InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)