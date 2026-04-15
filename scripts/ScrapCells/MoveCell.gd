extends ScrapCell
class_name MoveCell

@export var rotation: Vector3i = Vector3i.ZERO

@export var moveAmount: int = 1

@export var movement: Vector3i = Vector3i.BACK
func _init():
	cellName = "Move Cell"
	description = "This is a movement cell. It moves you in a direction."
	gridTileID = 9
	cellType = Type.MOVEMENT
	movement = rotation* moveAmount
func getRotation() -> Vector3i:
	return rotation

func setRotation(newRotation: Vector3i) -> void:
	rotation = newRotation
	movement = rotation * moveAmount

