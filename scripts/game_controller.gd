extends Node

@export var robotPool: Array[Robot]
@export var partPool: Array[SparePart]

@export var magnetBoat: Node3D

@export var cardPopup: Panel

signal processCard(card:Resource)

const BASE_MAX_ENERGY: int = 25

@export var fishInventory: Array[Loot] = []

@export var fightInventory: Array[SparePart]
@export var fightRoster: Array[Robot]
@export var totalEnergyBonus: int = 0

func _ready():
	_seed_initial_roster()
	_resolve_scene_nodes()

# Added by Copilot
func _seed_initial_roster() -> void:
	if not fightRoster.is_empty():
		return

	var seen_keys: Dictionary = {}
	for robot_template: Robot in robotPool:
		if robot_template == null:
			continue
		if robot_template.tier != 1:
			continue

		var key: String = "%s_%d" % [robot_template.name, int(robot_template.type)]
		if seen_keys.has(key):
			continue

		var seeded_robot: Robot = robot_template.duplicate(true)
		fightRoster.append(seeded_robot)
		seen_keys[key] = true

# Added by Copilot
func _resolve_scene_nodes() -> void:
	if magnetBoat == null or not is_instance_valid(magnetBoat):
		magnetBoat = get_tree().get_first_node_in_group("MagnetBoat")
	if cardPopup == null or not is_instance_valid(cardPopup):
		cardPopup = get_tree().get_first_node_in_group("CardPopup")

func bankLoot(loot: Array[Loot]):
	if loot.is_empty():
		return
	_resolve_scene_nodes()
	fishInventory.append_array(loot)
	if cardPopup != null and is_instance_valid(cardPopup):
		cardPopup.visible = true
	if magnetBoat != null and is_instance_valid(magnetBoat):
		magnetBoat.canMove = false
	processLoot(loot)
	fishInventory.clear()


func processLoot(loot: Array[Loot]):
	print("Robot Pool: ", robotPool.size(), " | Part Pool: ", partPool.size())

	for item in loot:
		print("Processing loot: ", item)
		if item.type == Loot.LootType.ROBOT:
			var robot_template: Robot = robotPool.filter(func(r): return r.tier == item.tier).pick_random()
			if robot_template == null:
				continue
			var robot: Robot = robot_template.duplicate(true)
			fightRoster.append(robot)
			emit_signal("processCard", robot)
		elif item.type == Loot.LootType.SPAREPART:
			var part_template: SparePart = partPool.filter(func(p): return p.tier == item.tier).pick_random()
			if part_template == null:
				continue
			var part: SparePart = part_template.duplicate(true)
			fightInventory.append(part)
			emit_signal("processCard", part)

# Added by Copilot
func consume_fight_part(part: SparePart) -> bool:
	var idx: int = fightInventory.find(part)
	if idx < 0:
		return false
	fightInventory.remove_at(idx)
	return true

# Added by Copilot
func add_fight_part(part: SparePart) -> void:
	if part == null:
		return
	fightInventory.append(part)

# Added by Copilot
func add_fight_robot(robot: Robot) -> void:
	if robot == null:
		return
	fightRoster.append(robot)

# Added by Copilot
func remove_fight_robot(robot: Robot) -> void:
	if robot == null:
		return
	var idx: int = fightRoster.find(robot)
	if idx >= 0:
		fightRoster.remove_at(idx)

# Added by Copilot
func create_spare_part_from_tier(tier: int) -> SparePart:
	var matching_parts: Array[SparePart] = partPool.filter(func(p): return p != null and p.tier == tier)
	var selected_template: SparePart = null
	if not matching_parts.is_empty():
		selected_template = matching_parts.pick_random()
	elif not partPool.is_empty():
		selected_template = partPool.pick_random()

	if selected_template == null:
		return null
	return selected_template.duplicate(true)

# Added by Copilot
func register_fight_energy_reward(stars: int) -> void:
	totalEnergyBonus += max(0, stars)

# Added by Copilot
func get_max_energy() -> int:
	return BASE_MAX_ENERGY + totalEnergyBonus
