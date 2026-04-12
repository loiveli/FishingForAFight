extends Resource
class_name Loot

enum LootType { ROBOT, SPAREPART, SCRAP }


@export_subgroup("Visuals")
@export var texture: Texture2D
@export var name: String

@export_subgroup("Gameplay")
@export var weight: int
@export var type: LootType
@export var tier: int
