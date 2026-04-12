extends VBoxContainer

@export var lootCardScene: PackedScene
@export var magnetBoat: Node3D

var lootList: Dictionary[Node, Loot] = {}

@export var lowWeightHolder: VBoxContainer
@export var highWeightHolder: VBoxContainer

func _ready():
	magnetBoat.connect("lootAdded", Callable(self , "addLoot"))
	magnetBoat.connect("lootDropped", Callable(self , "dropLoot"))


func addLoot(loot: Loot):
	var lootCard = lootCardScene.instantiate()
	lootCard.setup(loot)
	lootList[lootCard] = loot
	if loot.weight == 1:
		lowWeightHolder.add_child(lootCard)
	elif loot.weight == 2:
		highWeightHolder.add_child(lootCard)

func dropLoot(loot: Loot):
	if loot in lootList.values():
		print("Dropping loot: ", loot)
		var lootCard = lootList.find_key(loot)
		lootCard.queue_free()
		lootList.erase(lootCard)
