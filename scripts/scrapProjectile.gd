extends Node3D

class_name ScrapProjectile
var target: Vector3 = Vector3.ZERO
var speed: float = 10.0
var weapon: Weapon
var collisionLayer: int = 1
@export var collider: Area3D

var direction: Vector3 = Vector3.ZERO

func _ready():
	if not collider:
		collider = $Area3D
	if not target:
		target = position + direction * weapon.damageRange *10
	print("Projectile launched towards %s with direction %s and target %s" % [position, direction, target])
	collider.collision_layer = collisionLayer

func _physics_process(delta: float) -> void:

	
	if position.distance_to(target) < 0.1:
		queue_free()
		return
	else:
		position = position.move_toward(target, speed * delta)