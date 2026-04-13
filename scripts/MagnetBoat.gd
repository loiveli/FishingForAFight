extends Node3D

@export var energyBar: TextureProgressBar

var maxEnergy: int = 25
var energy: int = maxEnergy

@export var magnet: TextureRect

signal lootAdded(loot: Loot)
signal lootDropped(loot: Loot)
signal lootScanned(position: Vector3i)
signal resetScan()


var scanned: bool = false
var canMove: bool = true

var magnetActive: bool = false

@export var inventory: Array[Loot] = []

@export var seaOfScrap: GridMap

@export var inventoryUI: VBoxContainer

var _base_energy_bar_width: float = 0.0


func _ready():
	_sync_max_energy_from_progress()
	magnet.visible = magnetActive

# Added by Copilot
func _sync_max_energy_from_progress() -> void:
	maxEnergy = GameController.get_max_energy()
	energy = maxEnergy
	if energyBar != null:
		if _base_energy_bar_width <= 0.0:
			_base_energy_bar_width = energyBar.size.x
		var segment_width: float = _base_energy_bar_width / float(GameController.BASE_MAX_ENERGY)
		energyBar.custom_minimum_size.x = segment_width * float(maxEnergy)
		energyBar.size.x = energyBar.custom_minimum_size.x
		_update_energy_bar_atlas_regions()
		energyBar.max_value = maxEnergy
		energyBar.value = energy

# Added by Copilot
func _update_energy_bar_atlas_regions() -> void:
	if energyBar == null:
		return
	var region_width: float = 48.0 * float(maxEnergy)
	if energyBar.texture_under is AtlasTexture:
		var under_texture: AtlasTexture = energyBar.texture_under.duplicate()
		under_texture.region = Rect2(0, 0, region_width, 48)
		energyBar.texture_under = under_texture
	if energyBar.texture_progress is AtlasTexture:
		var progress_texture: AtlasTexture = energyBar.texture_progress.duplicate()
		progress_texture.region = Rect2(0, 0, region_width, 48)
		energyBar.texture_progress = progress_texture


func _process(delta):

	if canMove:
		handle_input(delta)





func handle_input(_delta):
	
	var movement := Vector3.ZERO

	if Input.is_action_just_released("move_forward"):
		movement = Vector3(0, 0, 1)
	elif Input.is_action_just_released("move_back"):
		movement = Vector3(0, 0, -1)
	elif Input.is_action_just_released("move_left"):
		movement = Vector3(1, 0, 0)
	elif Input.is_action_just_released("move_right"):
		movement = Vector3(-1, 0, 0)
	
	if movement != Vector3.ZERO:
		move(movement)
	if Input.is_action_just_released("magnet_toggle") && energy > total_move_cost():
		magnetActive = !magnetActive
		magnet.visible = magnetActive

	if Input.is_action_just_released("scan_loot"):
		emit_signal("lootScanned", position)
		energy -= 1
		energyBar.value = energy
		scanned = true


func total_move_cost():
	if inventory.size() <= 0:
		return 1
	return inventory.reduce(
		func(total, loot):
		return total + loot.weight,
		1
	)
	
	
func sortByWeight(lootA: Loot, lootB: Loot):
	return lootA.weight < lootB.weight


func move(movement: Vector3):
	
	
	position += movement
	
	var totalCost = total_move_cost()
	var lootTable = seaOfScrap.lootMap.get(position)
	if lootTable:
		if energy > totalCost:
			if magnetActive:
				print("Loot table found for position ", position," ", lootTable)
				var loot = lootTable.getRandomLoot()
				if loot:	
					print("Loot found: ", loot)
					inventory.append(loot)
					emit_signal("lootAdded", loot)
			elif !magnetActive and inventory.size() > 0:
				inventory.sort_custom(sortByWeight)
				var droppedLoot = inventory.pop_front()
				if lootTable:
					lootTable.addLoot(droppedLoot, 1)
					emit_signal("lootDropped", droppedLoot)
		elif inventory.size() > 0:
			magnetActive = false
			magnet.visible = magnetActive
			if inventory.size() > 0:
				inventory.sort_custom(sortByWeight)
				var droppedLoot = inventory.pop_front()
				emit_signal("lootDropped", droppedLoot)
				if lootTable:
					lootTable.addLoot(droppedLoot, 1)
		energy -= totalCost
	
	else:
		if scanned:
			scanned = false
			emit_signal("resetScan")
		GameController.bankLoot(inventory)
		for loot in inventory:
			emit_signal("lootDropped", loot)
		inventory.clear()
		energy = maxEnergy
		magnetActive = false
		magnet.visible = magnetActive

	energyBar.value = energy
	

	
