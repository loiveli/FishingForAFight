extends VBoxContainer

@export var functionLabel: Label

var tabTitle: String = ""


func setup(robot_function: RobotFunction) -> void:
	tabTitle = robot_function.name
	functionLabel.text = robot_function.description