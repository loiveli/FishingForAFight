extends Resource
class_name ScrapCell

enum Type {EMPTY, LOOT, MOVEMENT, SAFEZONE, CHARGE, MAGNET}

@export var cellName: String = "Empty Cell"

@export var description: String = "This is an empty cell. It does nothing."

@export var cellType: Type = Type.EMPTY

@export var gridTileID: int = 0

@export var moveCost: int = 1

