extends MagnetBoat

class_name EnemyBoat

var playerBoat: MagnetBoat

var targetPosition: Vector3

func _ready():
	super()
	if playerBoat == null:
		playerBoat = get_tree().get_first_node_in_group("PlayerBoat")
	targetPosition = playerBoat.global_transform.origin

func _process(delta: float) -> void:

	scrapCannon.look_at(playerBoat.global_transform.origin, Vector3.LEFT)
	scrapCannon.rotation.x = 0
	scrapCannon.rotation.z = 0

	if global_transform.origin.distance_to(targetPosition) > 1:
		look_at(targetPosition, Vector3.UP)
		moveBoat(-global_transform.basis.z * maxSpeed * delta)
	else:
		print("EnemyBoat at %s is attacking player at %s" % [global_transform.origin, playerBoat.global_transform.origin])
		if inventory.size() > 0:
			var weapon = inventory[0].weapon.duplicate() as Weapon
			if weapon and weapon.ammo > 0:
				weapon.ammo -= 1
				var projectile = scrapProjectileScene.instantiate() as Node3D
				projectile.weapon = weapon
				get_parent().add_child(projectile)
				projectile.global_transform.origin = global_transform.origin + Vector3(0, 0.5, 0) + global_transform.basis.z
				projectile.target = playerBoat.global_transform.origin + Vector3(0, 0.5, 0)
				print("EnemyBoat fired projectile towards ", playerBoat.global_transform.origin, " with weapon ", weapon)
				projectile.collisionLayer = 2 # Set to a different layer to avoid hitting other enemy boats
				if weapon.ammo <= 0:
					inventory.remove_at(0)
		targetPosition = playerBoat.global_transform.origin + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
		print("New target position for EnemyBoat is %s" % targetPosition)
		

	if inventory.size() < 2:
		magnetActive = true
	else:
		magnetActive = false
	
	
