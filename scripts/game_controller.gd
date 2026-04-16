extends Node

@export var robotPool: Array[Robot]
@export var partPool: Array[SparePart]

@export var magnetBoat: Node3D

@export var cardPopup: Panel

signal processCard(card:Resource)

const BASE_MAX_ENERGY: int = 25

@export var currentDay: int = 1

@export var fishInventory: Array[Loot] = []

@export var calendar: HBoxContainer

@export var uiControl: Control

@export var fightClub: Control

@export var fightInventory: Array[SparePart]
@export var fightRoster: Array[Robot]
@export var totalEnergyBonus: int = 0

@export var money: int = 100

func _ready():
	if not cardPopup:
		cardPopup = get_tree().get_first_node_in_group("CardPopup") as Panel

	if not fightClub:
		fightClub = get_tree().get_first_node_in_group("FightClub") as Control
	
	if not magnetBoat:
		magnetBoat = get_tree().get_first_node_in_group("MagnetBoat") as Node3D

	if not calendar:
		calendar = get_tree().get_first_node_in_group("Calendar") as HBoxContainer

	if not uiControl:
		uiControl = get_tree().get_first_node_in_group("UIControl") as Control



func bankLoot(loot: Array[Loot]):
	print("Banking loot: ", loot)
	print("Card Popup: ", cardPopup, " | Valid: ", is_instance_valid(cardPopup))
	print(cardPopup != null,is_instance_valid(cardPopup))
	if cardPopup != null and is_instance_valid(cardPopup):
		cardPopup.visible = true
	if magnetBoat != null and is_instance_valid(magnetBoat):
		magnetBoat.canMove = false
	processLoot(loot)


func proceedDay():
	if calendar != null and is_instance_valid(calendar):
		currentDay += 1
		calendar.updateDay(currentDay)
	if currentDay == 2 || currentDay == 5:
		fightClub.visible = true
		fightClub.openFightClub()
		magnetBoat.canMove = false
		uiControl.visible = false
	else:
		if currentDay > 5:
			currentDay = 1
		magnetBoat.energy = magnetBoat.maxEnergy
		magnetBoat.energyBar.value = magnetBoat.energy
		magnetBoat.energyLabel.text = str(magnetBoat.energy)
		fightClub.visible = false
		magnetBoat.canMove = true
		uiControl.visible = true


func processLoot(loot: Array[Loot]):
	print("Robot Pool: ", robotPool.size(), " | Part Pool: ", partPool.size())

	for item in loot:
		print("Processing loot: ", item)
		if item.type == Loot.LootType.ROBOT:
			var robot_template: Robot = robotPool.filter(func(r): return r.cardTier.tierIndex == item.cardTier.tierIndex).pick_random()
			if robot_template == null:
				continue
			var robot: Robot = robot_template.duplicate(true)
			fightRoster.append(robot)
			print("Added robot to roster: ", robot)
			emit_signal("processCard", robot)
		elif item.type == Loot.LootType.SPAREPART:
			var part_template: SparePart = partPool.filter(func(p): return p.cardTier.tierIndex == item.cardTier.tierIndex).pick_random()
			if part_template == null:
				continue
			var part: SparePart = part_template.duplicate(true)
			print("Adding part to fight inventory: ", part)
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
func create_spare_part_from_tier(tier: CardTier) -> SparePart:
	var matching_parts: Array[SparePart] = partPool.filter(func(p): return p != null and p.cardTier == tier)
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
	magnetBoat.maxEnergy += max(0, stars)*3

# Added by Copilot
func get_max_energy() -> int:
	return magnetBoat.maxEnergy
