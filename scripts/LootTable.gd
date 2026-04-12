extends Resource
class_name LootTable
@export var loot: Dictionary[Loot, int]


func getRandomLoot() -> Loot:
	var totalWeight = loot.values().reduce(func(total, weight): return total + weight, 0)
	var randomWeight = randi() % totalWeight
	
	for lootItem in loot.keys():
		randomWeight -= loot[lootItem]
		if randomWeight < 0:
			if lootItem.weight > 0:
				return lootItem
	return null

func addLoot(droppedLoot: Loot, count: int):
	if droppedLoot in self.loot:
		self.loot[droppedLoot] += count
	else:
		self.loot[droppedLoot] = count
