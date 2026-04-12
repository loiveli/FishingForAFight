extends Control
class_name UpgradeMarker

@export var slotContainer: HBoxContainer
@export var slotTexture: Texture2D = preload("res://sprites/selector.png")
@export var partTexture: Texture2D = preload("res://icon.svg")

const SLOT_NAME_PREFIX := "UpgradeSlot"
const ICON_NAME := "PartIcon"

# Added by Copilot
func _ready() -> void:
	if slotContainer == null:
		slotContainer = get_node_or_null("Slots")
	_sync_slot_textures()
	set_filled_slots(0)

# Added by Copilot
func set_filled_slots(filled: int) -> void:
	if slotContainer == null:
		return
	var clamped_filled: int = clampi(filled, 0, Robot.MAX_UPGRADES)
	for i in range(Robot.MAX_UPGRADES):
		var slot_node: Node = slotContainer.get_node_or_null("%s%d" % [SLOT_NAME_PREFIX, i])
		if slot_node == null or not (slot_node is TextureRect):
			continue
		var slot_rect: TextureRect = slot_node
		slot_rect.texture = slotTexture
		var part_icon_node: Node = slot_node.get_node_or_null(ICON_NAME)
		if part_icon_node == null or not (part_icon_node is TextureRect):
			continue
		var part_icon: TextureRect = part_icon_node
		part_icon.texture = partTexture
		part_icon.modulate = Color(1.0, 1.0, 1.0, 1.0) if i < clamped_filled else Color(1.0, 1.0, 1.0, 0.2)

# Added by Copilot
func _sync_slot_textures() -> void:
	if slotContainer == null:
		return
	for i in range(Robot.MAX_UPGRADES):
		var slot_node: Node = slotContainer.get_node_or_null("%s%d" % [SLOT_NAME_PREFIX, i])
		if slot_node == null or not (slot_node is TextureRect):
			continue
		var slot_rect: TextureRect = slot_node
		slot_rect.texture = slotTexture
		var part_icon_node: Node = slot_rect.get_node_or_null(ICON_NAME)
		if part_icon_node == null or not (part_icon_node is TextureRect):
			continue
		var part_icon: TextureRect = part_icon_node
		part_icon.texture = partTexture
