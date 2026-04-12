extends VBoxContainer

@export var fighterCardScene: PackedScene

# Added by Copilot
func _ready() -> void:
	add_to_group("fighter_roster")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	if custom_minimum_size.y < 600.0:
		custom_minimum_size.y = 600.0
	if custom_minimum_size.x < 160.0:
		custom_minimum_size.x = 160.0
	# Added by Copilot
	for child in get_children():
		if child is Control and child.has_method("setupCard"):
			child.queue_free()
	# Added by Copilot
	for robot: Robot in GameController.fightRoster:
		add_robot_card(robot)

# Added by Copilot
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not (data is Robot):
		return false
	return true

# Added by Copilot
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(at_position, data):
		return

	# Added by Copilot
	if _has_robot_card(data):
		return

	# Added by Copilot
	if fighterCardScene == null:
		return

	# Added by Copilot
	var fighter_card := fighterCardScene.instantiate()
	if fighter_card is Control and fighter_card.has_method("setupCard"):
		fighter_card.setupCard(data)
		add_child(fighter_card)

# Added by Copilot
func _has_robot_card(robot: Robot) -> bool:
	for child in get_children():
		if child is Control and child.has_method("setupCard") and child.get("robotCard") == robot:
			return true
	return false

# Added by Copilot
func add_robot_card(robot: Robot) -> void:
	if robot == null:
		return
	if _has_robot_card(robot):
		return
	if fighterCardScene == null:
		return

	var fighter_card := fighterCardScene.instantiate()
	if fighter_card is Control and fighter_card.has_method("setupCard"):
		fighter_card.setupCard(robot)
		add_child(fighter_card)

# Added by Copilot
func remove_robot_card(robot: Robot) -> void:
	for child in get_children():
		if child is Control and child.has_method("setupCard") and child.get("robotCard") == robot:
			child.queue_free()
			return
