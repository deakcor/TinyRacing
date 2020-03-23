extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name()=="Android":
		get_tree().change_scene("res://scenes/hud/controller.tscn")
	else:
		get_tree().change_scene("res://scenes/world.tscn")
