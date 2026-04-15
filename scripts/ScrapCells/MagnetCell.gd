extends ScrapCell
class_name MagnetCell

var lootTable: Array[Loot] = []

func _init():
	cellName = "Magnet Cell"
	description = "This is a magnet cell. It will steal your loot unless you can hack its systems."
	gridTileID = 6
	cellType = Type.MAGNET

func dropLoot(loot: Array[Loot]):
	lootTable.append_array(loot)

func getLoot() -> Array[Loot]:
	var returnedLoot = lootTable.duplicate()
	lootTable.clear()
	return returnedLoot
