extends Panel

@export var nameLabel: Label
@export var weightLabel: Label
@export var textureRect: TextureRect


func setup(loot: Loot):
	nameLabel.text = loot.name
	textureRect.texture = loot.texture
	weightLabel.text = "Weight: " + str(loot.weight)
	modulate = loot.cardTier.tierColor
	
