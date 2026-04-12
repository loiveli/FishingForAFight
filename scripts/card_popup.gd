extends Panel

@export var robotCard: PackedScene
@export var partCard: PackedScene

@export var cardLayout: HBoxContainer

func _ready():
	visible = false
	GameController.connect("processCard", Callable(self, "showCard"))
	# Added by Copilot
	var fight_club_btn := Button.new()
	fight_club_btn.text = "Fight Club"
	fight_club_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	fight_club_btn.pressed.connect(_go_to_fight_club)
	cardLayout.get_parent().add_child(fight_club_btn)

func closePopup():
	visible = false
	get_tree().get_first_node_in_group("MagnetBoat").canMove = true
	for child in cardLayout.get_children():
		child.queue_free()

# Added by Copilot
func _go_to_fight_club() -> void:
	visible = false
	var boat := get_tree().get_first_node_in_group("MagnetBoat")
	if boat != null:
		boat.canMove = false
	get_tree().change_scene_to_file("res://scenes/FightClub.tscn")


func showCard(card: Resource):
	if card is Robot:
		var robotInstance = robotCard.instantiate()
		robotInstance.setupCard(card)
		cardLayout.add_child(robotInstance)
		
	elif card is SparePart:
		var partInstance = partCard.instantiate()
		partInstance.setupCard(card)
		cardLayout.add_child(partInstance)
		
