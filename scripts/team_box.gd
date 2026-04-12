extends VBoxContainer

@export var fighterSlotScene: PackedScene
@export var initialSlots: int = 3
@export var maxSlots: int = 8
@export var maxGaps: int = 1

var _is_rebuilding: bool = false

# Added by Copilot
func _ready() -> void:
	add_to_group("team_box")
	_ensure_slots()

# Added by Copilot
func on_slot_changed(_changed_slot: Control = null) -> void:
	if _is_rebuilding:
		return
	_ensure_slots()

# Added by Copilot
func _ensure_slots() -> void:
	if fighterSlotScene == null:
		return

	_is_rebuilding = true

	var slots: Array = _get_slots()
	var filled_count: int = 0
	for slot in slots:
		if slot.slotted_robot != null:
			filled_count += 1

	var desired_slot_count: int = min(maxSlots, max(initialSlots, filled_count + 2))

	while get_child_count() < desired_slot_count:
		add_child(fighterSlotScene.instantiate())

	while get_child_count() > desired_slot_count:
		var extra_slot: Node = get_child(get_child_count() - 1)
		if extra_slot.get("slotted_robot") != null:
			break
		remove_child(extra_slot)
		extra_slot.queue_free()

	slots = _get_slots()
	_normalize_gaps(slots)

	_is_rebuilding = false

# Added by Copilot
func _get_slots() -> Array:
	var slots: Array = []
	for child in get_children():
		if child is Control and child.has_method("set_slot_data") and child.has_method("clear_slot_data"):
			slots.append(child)
	return slots

# Added by Copilot
func _normalize_gaps(slots: Array) -> void:
	if maxGaps < 1:
		return

	var last_filled_index: int = -1
	for i in range(slots.size()):
		if slots[i].slotted_robot != null:
			last_filled_index = i

	if last_filled_index <= 0:
		return

	var used_gap: bool = false
	for i in range(last_filled_index):
		if slots[i].slotted_robot != null:
			continue
		if not used_gap:
			used_gap = true
			continue

		var next_filled := i + 1
		while next_filled <= last_filled_index and slots[next_filled].slotted_robot == null:
			next_filled += 1

		if next_filled <= last_filled_index:
			slots[i].set_slot_data(slots[next_filled].slotted_robot)
			slots[next_filled].clear_slot_data()

# Added by Copilot
func can_accept_drop_on_slot(slot: Control) -> bool:
	var slots: Array = _get_slots()
	var slot_index: int = slots.find(slot)
	if slot_index < 0:
		return false

	var filled_count: int = 0
	for s in slots:
		if s.slotted_robot != null:
			filled_count += 1

	var enabled_targets: int = min(slots.size(), max(2, min(maxSlots, filled_count + 2)))
	return slot_index < enabled_targets
