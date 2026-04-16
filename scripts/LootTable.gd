extends Resource
class_name LootTable
@export var loot: Dictionary[Loot, int] = {}


func getRandomLoot() -> Loot:
	var totalWeight = loot.values().reduce(func(total, weight): return total + weight, 0)
	var lootArray: Array = []
	for lootItem in loot:
		for i in range(loot[lootItem]):
			lootArray.append(lootItem)

	if lootArray.size() > 0:
		var randomLoot = lootArray.pick_random()
		if randomLoot.cardTier.tierIndex >=0:
			return randomLoot
	return null

func addLoot(droppedLoot: Loot, count: int):
	if droppedLoot in self.loot:
		self.loot[droppedLoot] += count
	else:
		self.loot[droppedLoot] = count


func getLootTier() -> int:
	if loot.size() == 0:
		return -1
	var sorted = loot.keys()
	sorted.sort_custom(func(a, b): return loot[a] > loot[b])
	var top2 = sorted.slice(0, 2)
	return top2.map(func(l): return l.cardTier.tierIndex).reduce(func(a, b): return max(a, b))
