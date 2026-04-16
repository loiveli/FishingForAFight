extends Node3D

class_name MagnetBoat


@export_category("Gameplay Variables")
@export var maxEnergy: int = 15
var energy: int = maxEnergy

var healthPoints: int = 3

@export var maxSpeed: float = 2

var speed: float = 0
@export_category("UI elements")
@export var healthLabel: Label3D


@export_category("Collider")
@export var collider: Area3D
var canMove: bool = true

var magnetActive: bool = false



@export var scrapCannon: Node3D
@export var inventory: Array[Loot] = []
@export var seaOfScrap: GridMap
@export var scrapProjectileScene: PackedScene



var cellPosition: Vector3i


func _ready():
	if seaOfScrap == null:
		seaOfScrap = get_tree().get_first_node_in_group("SeaOfScrap") as GridMap
	if not collider:
		collider = $Area3D
	collider.area_entered.connect(takeDamage)
	healthLabel.text = "Health: %d" % healthPoints


func takeDamage(area: Area3D):
	print("Boat collided with ", area.name)
	var parent = area.get_parent()
	var amount = 0
	if parent is ScrapProjectile:
		var weapon = parent.weapon
		if weapon and weapon.damage > 0:
			amount = weapon.damage
	elif parent is EnemyBoat:
		amount = 1
	healthPoints -= amount
	if healthPoints <= 0:
		healthPoints = 0
	healthLabel.text = "Health: %d" % healthPoints	


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
	position += movement
	var newCellPos: Vector3i = position.round()
	if newCellPos != cellPosition:
		cellPosition = newCellPos
		var newCell: ScrapCell = seaOfScrap.cellMap.get(cellPosition) as ScrapCell

		if newCell:
			var total_Cost = magnetCost + newCell.moveCost
			energy -= total_Cost
			if energy <= 0:
				energy = 0
				magnetActive = false
				

			position += movement
			processCell(newCell)
	
	



func processCell(cell: ScrapCell):
	if !magnetActive && energy < maxEnergy:
		energy += 1
	match cell.cellType:
		ScrapCell.Type.EMPTY:
			pass
		ScrapCell.Type.LOOT:
			processMagnet(cell.lootTable)
		ScrapCell.Type.MOVEMENT:
			pass
		ScrapCell.Type.SAFEZONE:
			if inventory.size() > 0 || energy <= 0:
				energy = maxEnergy
				magnetActive = false
				inventory.clear()	
				
		ScrapCell.Type.CHARGE:
			energy = maxEnergy
		ScrapCell.Type.MAGNET:
			cell.dropLoot(inventory)
			inventory.clear()

			
			
	
	
func processMagnet(lootTable: LootTable):
	
	if lootTable:
		if energy > 0:
			if magnetActive:
				var loot = lootTable.getRandomLoot()
				if loot:	
					inventory.append(loot)
			elif !magnetActive and inventory.size() > 0:
				inventory.sort_custom(sortByWeight)
				var droppedLoot = inventory.pop_front()
				if lootTable:
					lootTable.addLoot(droppedLoot, 1)
		else:
			magnetActive = false
			if inventory.size() > 0:
				inventory.sort_custom(sortByWeight)
				var droppedLoot = inventory.pop_front()
				if lootTable:
					lootTable.addLoot(droppedLoot, 1)
	

	
