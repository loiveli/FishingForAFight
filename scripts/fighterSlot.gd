extends Control

var slotted_robot: Robot = null
var _drag_started_with_robot: bool = false

const SLOT_PANEL_PATH := "SlotPanel"
const PREVIEW_NODE_NAME := "RobotPreview"
const ATTACK_LABEL_NAME := "AttackPreviewLabel"
const HEALTH_LABEL_NAME := "HealthPreviewLabel"
const FIGHTER_CARD_SCENE: PackedScene = preload("res://scenes/fighter_card.tscn")
const SLOT_ATTACK_LABEL_SETTINGS: LabelSettings = preload("res://Resources/Settings/SlotAttackSettings.tres")
const SLOT_HEALTH_LABEL_SETTINGS: LabelSettings = preload("res://Resources/Settings/SlotHealthSettings.tres")
   
# Called on potential drop targets to check if they accept the data  
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Added by Copilot
	if _drag_started_with_robot:
		return false

	var parent_node := get_parent()
	if parent_node != null and parent_node.has_method("can_accept_drop_on_slot"):
		if not parent_node.can_accept_drop_on_slot(self):
			return false

	if data is Robot:
		return true
	if data is SparePart and slotted_robot != null and slotted_robot.can_accept_spare_part():
		return true

	return false

# Called when the drop is performed  
func _drop_data(at_position: Vector2, incoming_data: Variant) -> void:
	# Added by Copilot
	if not _can_drop_data(at_position, incoming_data):
		return

	if incoming_data is Robot:
		if slotted_robot != null and slotted_robot != incoming_data:
			_add_robot_to_roster(slotted_robot)
		set_slot_data(incoming_data)
		_remove_robot_from_roster(incoming_data)
		return

	if incoming_data is SparePart and slotted_robot != null:
		_apply_spare_part_upgrade(incoming_data)

# Added by Copilot
func set_slot_data(robot: Robot) -> void:
	slotted_robot = robot
	_update_slot_preview()
	_notify_team_box_slot_changed()

# Added by Copilot
func clear_slot_data() -> void:
	slotted_robot = null
	_update_slot_preview()
	_notify_team_box_slot_changed()

# Added by Copilot
func _update_slot_preview() -> void:
	var slot_panel := get_node_or_null(SLOT_PANEL_PATH)
	if slot_panel == null:
		return

	var preview := slot_panel.get_node_or_null(PREVIEW_NODE_NAME)
	if preview == null:
		preview = TextureRect.new()
		preview.name = PREVIEW_NODE_NAME
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.custom_minimum_size = Vector2(54, 54)
		preview.position = Vector2(3, 3)
		slot_panel.add_child(preview)

	preview.texture = null if slotted_robot == null else slotted_robot.texture

	# Added by Copilot
	var attack_label := slot_panel.get_node_or_null(ATTACK_LABEL_NAME)
	if attack_label == null:
		attack_label = Label.new()
		attack_label.name = ATTACK_LABEL_NAME
		attack_label.position = Vector2(3, 0)
		attack_label.size = Vector2(24, 16)
		attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		attack_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		attack_label.label_settings = SLOT_ATTACK_LABEL_SETTINGS
		slot_panel.add_child(attack_label)

	# Added by Copilot
	var health_label := slot_panel.get_node_or_null(HEALTH_LABEL_NAME)
	if health_label == null:
		health_label = Label.new()
		health_label.name = HEALTH_LABEL_NAME
		health_label.position = Vector2(33, 0)
		health_label.size = Vector2(24, 16)
		health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		health_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		health_label.label_settings = SLOT_HEALTH_LABEL_SETTINGS
		slot_panel.add_child(health_label)

	if slotted_robot == null:
		attack_label.text = ""
		health_label.text = ""
		tooltip_text = ""
	else:
		attack_label.text = str(slotted_robot.attackPower)
		health_label.text = str(slotted_robot.health)
		tooltip_text = " "

# Added by Copilot
func _make_custom_tooltip(_for_text: String) -> Object:
	if slotted_robot == null:
		return null

	var tooltip_card := FIGHTER_CARD_SCENE.instantiate()
	if tooltip_card is Control and tooltip_card.has_method("setupCard"):
		tooltip_card.setupCard(slotted_robot)
		tooltip_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tooltip_card.scale = Vector2(0.9, 0.9)
		return tooltip_card

	return null

# Added by Copilot
func _get_drag_data(_at_position: Vector2) -> Variant:
	if slotted_robot == null:
		return null

	_drag_started_with_robot = true

	var preview_root := Control.new()
	var preview_panel := Panel.new()
	preview_panel.custom_minimum_size = Vector2(60, 60)
	preview_root.add_child(preview_panel)

	if slotted_robot.texture != null:
		var preview_texture := TextureRect.new()
		preview_texture.texture = slotted_robot.texture
		preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview_texture.custom_minimum_size = Vector2(54, 54)
		preview_texture.position = Vector2(3, 3)
		preview_panel.add_child(preview_texture)

	preview_root.position = Vector2(-30, -30)
	set_drag_preview(preview_root)

	return slotted_robot

# Added by Copilot
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if _drag_started_with_robot and get_viewport().gui_is_drag_successful():
			clear_slot_data()
		_drag_started_with_robot = false

# Added by Copilot
func _remove_robot_from_roster(robot: Robot) -> void:
	var roster := get_tree().get_first_node_in_group("fighter_roster")
	if roster != null and roster.has_method("remove_robot_card"):
		roster.remove_robot_card(robot)

# Added by Copilot
func _add_robot_to_roster(robot: Robot) -> void:
	var roster := get_tree().get_first_node_in_group("fighter_roster")
	if roster != null and roster.has_method("add_robot_card"):
		roster.add_robot_card(robot)

# Added by Copilot
func _notify_team_box_slot_changed() -> void:
	var parent_node := get_parent()
	if parent_node != null and parent_node.has_method("on_slot_changed"):
		parent_node.on_slot_changed(self)

# Added by Copilot
func refresh_slot_visuals() -> void:
	_update_slot_preview()

# Added by Copilot
func set_active_indicator(active: bool) -> void:
	var slot_panel := get_node_or_null(SLOT_PANEL_PATH)
	if slot_panel == null:
		return
	if active:
		slot_panel.modulate = Color(1.4, 1.4, 0.4)
	else:
		slot_panel.modulate = Color(1.0, 1.0, 1.0)

# Added by Copilot
func _apply_spare_part_upgrade(part: SparePart) -> void:
	if part == null or slotted_robot == null:
		return
	if not slotted_robot.can_accept_spare_part():
		return
	if not GameController.consume_fight_part(part):
		return

	if not slotted_robot.apply_spare_part(part):
		GameController.add_fight_part(part)
		return

	var inventory := get_tree().get_first_node_in_group("spare_parts_inventory")
	if inventory != null and inventory.has_method("remove_part_card"):
		inventory.remove_part_card(part)

	_update_slot_preview()