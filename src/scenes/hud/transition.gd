extends CanvasLayer

var open
var nom_scene
var param
func _ready():
	var val=1 if open else 0
	
	$Tween.interpolate_property(get_node("transition"), "cutoff", 1-val, val, 0.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
func init(nom_scene,open):
	self.nom_scene=nom_scene
	self.open=open
	self.param=param
	var transition
	transition=preload("res://scenes/hud/transition_effect.tscn").instance()
	if transition!=null:
		add_child(transition)


func _on_Tween_tween_completed(object, key):
	if open:
		var current_scene = get_tree().get_current_scene()
		current_scene.free()
		# Load new scene.
		var s = ResourceLoader.load("res://scenes/"+nom_scene+".tscn")
		
		# Instance the new scene.
		current_scene = s.instance()
		# Add it to the active scene, as child of root.
		get_tree().get_root().add_child(current_scene)
		
		# Optional, to make it compatible with the SceneTree.change_scene() API.
		get_tree().set_current_scene(current_scene)
		open=false
		var val=1 if open else 0
		$Tween.interpolate_property(get_node("transition"), "cutoff", 1-val, val, 0.5, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		get_tree().get_root().set_disable_input(false)
		queue_free()
		
