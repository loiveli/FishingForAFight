extends GridMap

var gridmap: GridMap

var cellMap: Dictionary[Vector3i, ScrapCell] = {}

@export var highLootTable: LootTable
@export var lowLootTable: LootTable
@export var emptyLootTable: LootTable

@export var magnetShip: Node3D

@export var cellTypes: Array[ScrapCell]

@export var tiers: Array[CardTier]

@export var view_camera: Camera3D
@export var toolTip: Label3D


var plane: Plane





func _ready():
	gridmap = self
	initializeSeaOfScrap()
	generateMeshLibrary()
	
	
	magnetShip = get_tree().get_first_node_in_group("MagnetBoat")
	magnetShip.connect("lootScanned", scanHighlight)
	magnetShip.connect("resetScan", resetTiles)


func initializeSeaOfScrap():
	cellMap.clear()
	for cellType in cellTypes:
		for cell in gridmap.get_used_cells_by_item(cellType.gridTileID):
			var cellObject = cellType.duplicate_deep()
			var cellPos = cell
			if cellObject.cellType == ScrapCell.Type.MOVEMENT:
				cellObject.setRotation(get_cell_item_basis(cellPos).y)
				print("Cell at %s has movement %s" % [cellPos, get_cell_item_basis(cellPos)])
			
			cellMap[cellPos] = cellObject

func _process(delta: float) -> void:
	return
	
		
		

func getTileMeshID(tileID: int, tier: int = -1) -> int:
	if tier == -1:
		return tileID
	return (tier + 2) * 10 + tileID

func generateMeshLibrary():
	var base_library: MeshLibrary = mesh_library
	for tier in tiers:
		for base_id in range(1, 6):
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
	for cell in cellMap.keys().filter(func(c): return c.distance_to(scanPosition) <= 2):
		var cellPos = cell
		var cellObject = cellMap[cell]
		var lootTable = null
		if cellObject.cellType == ScrapCell.Type.LOOT:
			lootTable = cellObject.lootTable
		else:
			continue
		var lootTier = cellObject.tier
		var tileID = get_cell_item(cellPos) % 10
		set_cell_item(cellPos, getTileMeshID(tileID, lootTier))


func resetTiles():
	for cell in cellMap.keys():
		var cellPos = cell
		var tileID = get_cell_item(cellPos) % 10
		set_cell_item(cellPos, tileID)
