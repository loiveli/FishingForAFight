extends Node3D



func _process(delta):

	handle_input(delta)

# Handle input

func handle_input(_delta):
	
	# Rotation
	
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	
	
	

	if Input.is_action_just_pressed("move_left") || Input.is_action_just_pressed("move_forward") || Input.is_action_just_pressed("move_back") && Input.is_action_just_pressed("move_right"):
		move(input.normalized())


