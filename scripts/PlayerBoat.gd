extends MagnetBoat

class_name PlayerBoat


@export_category("UI Elements")
@export var energyBar: TextureProgressBar
@export var magnet: TextureRect
@export var view_camera: Camera3D
signal lootUpdated(newInventory: Array[Loot])
@export var inventoryUI: VBoxContainer
@export var energyLabel: Label


signal lootScanned(position: Vector3i)
signal resetScan()



var scanned: bool = false


var plane: Plane




func _ready():
	super()
	magnet.visible = magnetActive
	plane = Plane(Vector3.UP, Vector3.ZERO)
	
	if view_camera == null:
		view_camera = get_viewport().get_camera_3d()


func _process(delta):

	if canMove:
		handle_input(delta)

	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var world_position = plane.intersects_ray(
	view_camera.project_ray_origin(mouse_pos),
	view_camera.project_ray_normal(mouse_pos))

	var gridmap_position = Vector3(round(world_position.x), 0, round(world_position.z))

	if scrapCannon:
		scrapCannon.look_at(world_position, Vector3.LEFT)
		scrapCannon.rotation.x = 0
		scrapCannon.rotation.z = 0
	if Input.is_action_just_pressed("click") and inventory.size() > 0:
		var weapon = inventory[0].weapon.duplicate() as Weapon
		if weapon and weapon.ammo > 0:
			weapon.ammo -= 1
			var projectile = scrapProjectileScene.instantiate() as Node3D
			
			
			projectile.weapon = weapon
			
			get_parent().add_child(projectile)
			projectile.global_transform.origin = global_transform.origin + Vector3(0, 0.5, 0) + global_transform.basis.z
			projectile.target = projectile.global_transform.origin + projectile.global_transform.origin.direction_to(gridmap_position) * weapon.damageRange * 10
			print("Fired projectile towards ", gridmap_position, " with weapon ", weapon)

			
			if weapon.ammo <= 0:
				inventory.remove_at(0)
			emit_signal("lootUpdated", inventory)




func handle_input(_delta: float):
	
	if abs(speed) < maxSpeed:
		speed += Input.get_axis("move_back", "move_forward") * 0.01
	if abs(speed) > 0 && Input.get_axis("move_back", "move_forward") == 0:
		speed = lerpf(speed, 0, 0.2 * _delta)
		
	rotate_y(Input.get_axis( "move_right","move_left") * 0.5*_delta)
	
	if speed != 0:
		moveBoat(global_transform.basis.z * speed * _delta)
	if Input.is_action_just_released("magnet_toggle") && energy > total_inventory_weight():
		magnetActive = !magnetActive
		magnet.visible = magnetActive

	if Input.is_action_just_released("scan_loot"):
		emit_signal("lootScanned", position)
		energy -= 1
		energyBar.value = energy
		energyLabel.text = str(energy)
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
				magnet.visible = magnetActive
			energyBar.value = energy
			energyLabel.text = str(energy)
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
				magnet.visible = magnetActive
				inventory.clear()
				emit_signal("lootUpdated", inventory)
				
				if scanned:
					scanned = false
					emit_signal("resetScan")
				
				
		ScrapCell.Type.CHARGE:
			energy = maxEnergy
			energyBar.value = energy
		ScrapCell.Type.MAGNET:
			cell.dropLoot(inventory)
			inventory.clear()
			emit_signal("lootUpdated", inventory)
			
			
	
	
func processMagnet(lootTable: LootTable):
	
	if lootTable:
		if energy > 0:
			if magnetActive:

				var loot = lootTable.getRandomLoot()
				if loot:	

					inventory.append(loot)
					emit_signal("lootUpdated", inventory)
			elif !magnetActive and inventory.size() > 0:
				inventory.sort_custom(sortByWeight)
				var droppedLoot = inventory.pop_front()
				if lootTable:
					lootTable.addLoot(droppedLoot, 1)
					emit_signal("lootUpdated", inventory)
		else:
			magnetActive = false
			magnet.visible = magnetActive
			if inventory.size() > 0:
				inventory.sort_custom(sortByWeight)
				var droppedLoot = inventory.pop_front()
				emit_signal("lootUpdated", inventory)
				if lootTable:
					lootTable.addLoot(droppedLoot, 1)
	

	

