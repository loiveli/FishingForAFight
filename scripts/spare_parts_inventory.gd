extends VBoxContainer

@export var partCardScene: PackedScene

# Added by Copilot
func _ready() -> void:
	add_to_group("spare_parts_inventory")
	update_inventory_display()



func update_inventory_display() -> void:
	for child in get_children():
		if child is Control and child.has_method("setupCard"):
			child.queue_free()
	for part in GameController.fightInventory:
		add_part_card(part)
# Added by Copilot
func add_part_card(part: SparePart) -> void:
	if part == null:
		return
	if partCardScene == null:
		return

	var part_card := partCardScene.instantiate()
	if part_card is Control and part_card.has_method("setupCard"):
		part_card.setupCard(part)
		add_child(part_card)

# Added by Copilot
func remove_part_card(part: SparePart) -> void:
	for child in get_children():
		if child is Control and child.has_method("setupCard") and child.get("partCard") == part:
			child.queue_free()
			return
