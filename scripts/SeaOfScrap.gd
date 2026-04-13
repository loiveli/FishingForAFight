extends GridMap

var gridmap: GridMap

var lootMap: Dictionary[Vector3i, LootTable] = {}

@export var highLootTable: LootTable
@export var lowLootTable: LootTable
@export var emptyLootTable: LootTable

@export var magnetShip: Node3D

@export var tiers: Array[CardTier]

func _ready():
	gridmap = self
	generateMeshLibrary()
	for cell in gridmap.get_used_cells_by_item(3):
		lootMap[cell] = lowLootTable
	for cell in gridmap.get_used_cells_by_item(2):
		lootMap[cell] = highLootTable
	for cell in gridmap.get_used_cells_by_item(1):
		lootMap[cell] = emptyLootTable
	
	magnetShip = get_tree().get_first_node_in_group("MagnetBoat")
	magnetShip.connect("lootScanned", scanHighlight)
	magnetShip.connect("resetScan", resetTiles)



func getTileMeshID(tileID: int, tier: int = -1) -> int:
	if tier == -1:
		return tileID
	return (tier + 2) * 10 + tileID

func generateMeshLibrary():
	var base_library: MeshLibrary = mesh_library
	for tier in tiers:
		for base_id in range(1, 4):
			var base_mesh: Mesh = base_library.get_item_mesh(base_id).duplicate()
			for surface_idx in base_mesh.get_surface_count():
				var mat = base_mesh.surface_get_material(surface_idx)
				if mat == null:
					continue
				var new_mat: StandardMaterial3D = mat.duplicate()
				new_mat.albedo_color = new_mat.albedo_color * tier.tierColor
				base_mesh.surface_set_material(surface_idx, new_mat)
			var new_id = getTileMeshID(base_id, tier.tierIndex)
			base_library.create_item(new_id)
			base_library.set_item_mesh(new_id, base_mesh)
			base_library.set_item_name(new_id, "Tier%s_%d" % [tier.tierIndex, base_id])
			var shapes = base_library.get_item_shapes(base_id)
			if shapes.size() > 0:
				base_library.set_item_shapes(new_id, shapes)


func scanHighlight(scanPosition: Vector3i):
	for cell in lootMap.keys().filter(func(c): return c.distance_to(scanPosition) <= 2):
		var cellPos = cell
		var lootTable = lootMap[cell]
		if lootTable == null:
			continue
		var lootTier = lootTable.getLootTier()
		var tileID = get_cell_item(cellPos) % 10
		set_cell_item(cellPos, getTileMeshID(tileID, lootTier))


func resetTiles():
	for cell in lootMap.keys():
		var cellPos = cell
		var tileID = get_cell_item(cellPos) % 10
		set_cell_item(cellPos, tileID)
