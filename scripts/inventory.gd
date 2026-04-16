extends VBoxContainer

@export var lootCardScene: PackedScene
@export var magnetBoat: Node3D




func _ready():
	if magnetBoat == null:
		magnetBoat = get_tree().get_first_node_in_group("PlayerBoat")
	magnetBoat.connect("lootUpdated", Callable(self , "updateInventory"))



func updateInventory(newInventory: Array[Loot]):
	# Clear existing inventory UI
	for child in get_children():
		child.queue_free()
	
	for loot in newInventory:
		var lootCard = lootCardScene.instantiate()
		lootCard.setup(loot)
		add_child(lootCard)
