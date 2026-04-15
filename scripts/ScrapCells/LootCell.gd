extends ScrapCell
class_name LootCell

@export var lootTable: LootTable
@export_range(0, 4) var tier: int
func _init():
	cellName = "Loot Cell"
	description = "This is a loot cell. It contains valuable items."
	gridTileID = tier + 1
	cellType = Type.LOOT
