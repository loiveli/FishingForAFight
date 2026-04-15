extends ScrapCell
class_name ChargeCell

@export var chargeAmount: int = 10


func _init():
	cellName = "Charge Cell"
	description = "This is a charge cell. It gives you %d energy." % chargeAmount
	gridTileID = 7
	cellType = Type.CHARGE

func charge() -> int:
	return chargeAmount