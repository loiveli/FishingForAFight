extends Panel

@export var robotCard: PackedScene
@export var partCard: PackedScene

@export var cardLayout: HBoxContainer

func _ready():

	GameController.connect("processCard", Callable(self, "showCard"))
	

func closePopup():
	visible = false
	GameController.proceedDay()
	for child in cardLayout.get_children():
		child.queue_free()



func showCard(card: Resource):
	if card is Robot:
		var robotInstance = robotCard.instantiate()
		robotInstance.setupCard(card)
		cardLayout.add_child(robotInstance)
		
	elif card is SparePart:
		var partInstance = partCard.instantiate()
		partInstance.setupCard(card)
		cardLayout.add_child(partInstance)
		
