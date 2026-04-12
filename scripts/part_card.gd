extends Control

@export var nameLabel: Label
@export var healthLabel: Label
@export var attackLabel: Label
@export var textureRect: TextureRect
@export var functionContainer: TabContainer
@export var functionPanelScene: PackedScene
@export var fadeInSeconds: float = 0.5
@export var partCard: SparePart
var _drag_started_with_part: bool = false
const UPGRADE_MARKER_PATH := "CardPanel/CardLayout/UpgradeMarker"
const RUST_BAR_PATH := "CardPanel/CardLayout/RustBar"

# Added by Copilot
func _ready() -> void:
	_set_children_mouse_filter_ignore(self)
	var upgrade_marker := get_node_or_null(UPGRADE_MARKER_PATH)
	if upgrade_marker != null and upgrade_marker is Control:
		upgrade_marker.visible = false
	var rust_bar := get_node_or_null(RUST_BAR_PATH)
	if rust_bar != null and rust_bar is Control:
		rust_bar.visible = false
	if partCard != null:
		setupCard(partCard)

# Added by Copilot
func _set_children_mouse_filter_ignore(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_filter_ignore(child)

func setupCard(part: SparePart):
	
	self.partCard = part
	
	nameLabel.text = part.name
	healthLabel.text = str(part.health)
	attackLabel.text = str(part.attack)
	textureRect.texture = part.texture
	if part.functions.size() > 0 and functionPanelScene != null:
		functionContainer.visible = true
		for function in part.functions:
			var functionPanel = functionPanelScene.instantiate()
			functionPanel.setup(function)
			functionContainer.add_child(functionPanel)
	else:
		functionContainer.visible = false
	
	_fadeIn()


func _fadeIn():
	var startColor = self_modulate
	startColor.a = 0.0
	self_modulate = startColor

	var tween = create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, fadeInSeconds)

# Added by Copilot
func _get_drag_data(_at_position: Vector2) -> Variant:
	if partCard == null:
		return null

	_drag_started_with_part = true
	self.modulate = Color(1.0, 1.0, 1.0, 0.6)

	var preview := get_node("CardPanel").duplicate()
	if preview is Control:
		preview.scale = Vector2(0.75, 0.75)
		preview.position = -(preview.custom_minimum_size * 0.5 * preview.scale)
		set_drag_preview(preview)

	return partCard

# Added by Copilot
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		self.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if _drag_started_with_part and get_viewport().gui_is_drag_successful():
			var inventory := get_tree().get_first_node_in_group("spare_parts_inventory")
			if inventory != null and inventory.has_method("remove_part_card"):
				inventory.remove_part_card(partCard)
		_drag_started_with_part = false

# Added by Copilot
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return false
		
