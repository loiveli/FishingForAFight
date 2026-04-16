extends HBoxContainer

@export var day: int = 1

@export var dayCards: Array[Panel]


func _ready():
	if dayCards.size() == 0:
		dayCards = get_children() as Array[Panel]
	updateDay(day)

func updateDay(newDay: int):
	day = newDay
	for i in range(dayCards.size()):
		var dayColor: Color = Color(1, 1, 1, 1)
		if i == day-1:
			dayColor = Color(0, 0, 1, 1)
		dayCards[i].self_modulate = dayColor
		dayCards[i].modulate = dayColor
