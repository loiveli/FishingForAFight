extends GridMap

var gridmap: GridMap

var lootMap: Dictionary[Vector3i, LootTable] = {}

@export var highLootTable: LootTable
@export var lowLootTable: LootTable
@export var emptyLootTable: LootTable

func _ready():

	gridmap = self

	for cell in gridmap.get_used_cells_by_item(3):
		lootMap[cell] = lowLootTable
	for cell in gridmap.get_used_cells_by_item(2):
		lootMap[cell] = highLootTable
	for cell in gridmap.get_used_cells_by_item(1):
		lootMap[cell] = emptyLootTable
