extends Resource
class_name Robot

enum RobotType { THINKER, CRUSHER, SPLITTER, BUILDER}

@export var name: String
@export var texture: Texture2D
@export var health: int
@export var attackPower: int
@export var functions: Array[RobotFunction]
@export var type: RobotType
@export var tier: int
@export var upgradeCount: int = 0
@export var fightsCompleted: int = 0

const MAX_UPGRADES: int = 3
const MAX_FIGHTS_BEFORE_BREAK: int = 3

# Added by Copilot
func can_accept_spare_part() -> bool:
	return upgradeCount < MAX_UPGRADES

# Added by Copilot
func apply_spare_part(part: SparePart) -> bool:
	if part == null:
		return false
	if not can_accept_spare_part():
		return false

	attackPower += part.attack
	health = max(0, health + part.health)
	for robot_function in part.functions:
		if robot_function != null:
			functions.append(robot_function)
	upgradeCount += 1
	return true

# Added by Copilot
func register_completed_fight() -> void:
	fightsCompleted += 1

# Added by Copilot
func get_rust_ratio() -> float:
	return clamp(float(fightsCompleted) / float(MAX_FIGHTS_BEFORE_BREAK), 0.0, 1.0)

# Added by Copilot
func is_broken() -> bool:
	return fightsCompleted >= MAX_FIGHTS_BEFORE_BREAK


