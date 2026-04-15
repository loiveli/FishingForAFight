extends Node3D

@export var energyBar: TextureProgressBar

var maxEnergy: int = 25
var energy: int = maxEnergy

@export var magnet: TextureRect

signal lootAdded(loot: Loot)
signal lootDropped(loot: Loot)
signal lootScanned(position: Vector3i)
signal resetScan()

var moveCount: int = 0

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
		moveBoat(movement)
	if Input.is_action_just_released("magnet_toggle") && energy > total_inventory_weight():
		magnetActive = !magnetActive
		magnet.visible = magnetActive

	if Input.is_action_just_released("scan_loot"):
		emit_signal("lootScanned", position)
		energy -= 1
		energyBar.value = energy
		scanned = true


func total_inventory_weight():
	if inventory.size() <= 0:
		return 0
	return inventory.reduce(
		func(total, loot):
		return total + loot.weight,
		0
	)
	
	
func sortByWeight(lootA: Loot, lootB: Loot):
	return lootA.weight < lootB.weight


func moveBoat(movement: Vector3):
	var magnetCost = total_inventory_weight()
	
	var newCell: ScrapCell = seaOfScrap.cellMap.get(position+movement)
	if newCell:
		var total_Cost = magnetCost + newCell.moveCost
		energy -= total_Cost
		energyBar.value = energy
		position += movement
		processCell(newCell)
	
	



func processCell(cell: ScrapCell):
	match cell.cellType:
		ScrapCell.Type.EMPTY:
			moveCount = 0
			pass
		ScrapCell.Type.LOOT:
			moveCount = 0
			processMagnet(cell.lootTable)
		ScrapCell.Type.MOVEMENT:
			if moveCount < 2:
				position += cell.movement as Vector3
				moveCount += 1
		ScrapCell.Type.SAFEZONE:
			moveCount = 0
			if inventory.size() > 0 || energy <= 0:
				energy = maxEnergy
				magnetActive = false
				magnet.visible = magnetActive
				GameController.bankLoot(inventory)
				for loot in inventory:
					emit_signal("lootDropped", loot)
				inventory.clear()
				if scanned:
					scanned = false
					emit_signal("resetScan")
				
				
		ScrapCell.Type.CHARGE:
			moveCount = 0
			energy = maxEnergy
			energyBar.value = energy
		ScrapCell.Type.MAGNET:
			cell.dropLoot(inventory)
			for loot in inventory:
				emit_signal("lootDropped", loot)
			inventory.clear()
			
	
	
func processMagnet(lootTable: LootTable):
	
	if lootTable:
		if energy > 0:
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
		else:
			magnetActive = false
			magnet.visible = magnetActive
			if inventory.size() > 0:
				inventory.sort_custom(sortByWeight)
				var droppedLoot = inventory.pop_front()
				emit_signal("lootDropped", droppedLoot)
				if lootTable:
					lootTable.addLoot(droppedLoot, 1)
	

	
