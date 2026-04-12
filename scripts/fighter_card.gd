extends Control

@export var nameLabel: Label
@export var healthLabel: Label
@export var attackLabel: Label
@export var typeLabel: Label
@export var textureRect: TextureRect
@export var rustBar: Control
@export var functionContainer: TabContainer
@export var upgradeMarker: Control
@export var functionPanelScene: PackedScene
@export var fadeInSeconds: float = 0.5

@export var robotCard: Robot

# Added by Copilot
func _ready() -> void:
	_set_children_mouse_filter_ignore(self)
	if robotCard != null:
		setupCard(robotCard)

# Added by Copilot
func _set_children_mouse_filter_ignore(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_filter_ignore(child)

func setupCard(robot: Robot):
	self.robotCard = robot
	
	nameLabel.text = robot.name
	healthLabel.text = str(robot.health)
	attackLabel.text = str(robot.attackPower)
	typeLabel.text = Robot.RobotType.find_key(robot.type)
	textureRect.texture = robot.texture
	_update_rust_bar(robot)
	_update_upgrade_marker(robot)
	# Added by Copilot
	for child in functionContainer.get_children():
		functionContainer.remove_child(child)
		child.queue_free()
	for i in range(robot.functions.size()):
		var robot_function: RobotFunction = robot.functions[i]
		var functionPanel = functionPanelScene.instantiate()
		functionPanel.setup(robot_function)
		functionContainer.add_child(functionPanel)
		functionContainer.set_tab_title(i, robot_function.name)
	_fadeIn()


func _fadeIn():
	var startColor = self_modulate
	startColor.a = 0.0
	self_modulate = startColor

	var tween = create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, fadeInSeconds)
		

func _get_drag_data(_at_position: Vector2) -> Variant:
	if robotCard == null:
		return null

	self.modulate = Color(1.0, 1.0, 1.0, 0.6)
	# Added by Copilot
	var preview: Control = get_node("CardPanel").duplicate()
	preview.scale = Vector2(0.75, 0.75)
	preview.position = -(preview.custom_minimum_size * 0.5 * preview.scale)
	set_drag_preview(preview)
	# Added by Copilot
	return robotCard

# Added by Copilot
func set_modulate_to_normal() -> void:
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)

# Added by Copilot
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		set_modulate_to_normal()

# Added by Copilot
func _update_upgrade_marker(robot: Robot) -> void:
	if upgradeMarker == null:
		return
	var filled: int = clampi(robot.upgradeCount, 0, Robot.MAX_UPGRADES)
	if upgradeMarker.has_method("set_filled_slots"):
		upgradeMarker.set_filled_slots(filled)

# Added by Copilot
func _update_rust_bar(robot: Robot) -> void:
	if rustBar == null:
		return
	var filled: int = clampi(robot.fightsCompleted, 0, Robot.MAX_FIGHTS_BEFORE_BREAK)
	if rustBar.has_method("set_filled_segments"):
		rustBar.set_filled_segments(filled)

# Added by Copilot
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is SparePart and robotCard != null

# Added by Copilot
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not (data is SparePart):
		return
	if robotCard == null:
		return
	if not robotCard.can_accept_spare_part():
		return
	if not GameController.consume_fight_part(data):
		return

	if not robotCard.apply_spare_part(data):
		GameController.add_fight_part(data)
		return

	var inventory := get_tree().get_first_node_in_group("spare_parts_inventory")
	if inventory != null and inventory.has_method("remove_part_card"):
		inventory.remove_part_card(data)

	setupCard(robotCard)