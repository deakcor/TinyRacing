extends Node

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	AirConsole.connect("is_ready",self,"_on_AirConsole_is_ready")
func _changer_scene(nom_scene):
	get_tree().get_root().set_disable_input(true)
	var transition=preload("res://scenes/hud/transition.tscn").instance()
	transition.init(nom_scene,true)
	get_parent().get_child(0).add_child(transition)
func _on_AirConsole_is_ready(join_code):
	AirConsole.ready=true
