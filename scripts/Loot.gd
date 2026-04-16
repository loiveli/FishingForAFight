extends Resource
class_name Loot




@export_subgroup("Visuals")
@export var texture: Texture2D
@export var name: String

@export_subgroup("Gameplay")
@export var weight: int = 1
@export var value: int = 0
@export var cardTier: CardTier
@export var weapon: Weapon

