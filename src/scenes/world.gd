extends Spatial

onready var im = get_node("draw")
var clear_next:=false
func clear_next_draw():

	clear_next=true

func update_draw(veca:Vector3,vecb:Vector3):
	if clear_next:
		im.clear()
		clear_next=false
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	im.add_vertex(veca)
	im.add_vertex(vecb)
	im.end()
	$anim_draw.stop()
	$anim_draw.play("fade")

func _process(delta):
	$camera_cont.translation=$player_car.translation
	$camera_cont.rotation.y=lerp_angle($camera_cont.rotation.y,$player_car.rotation.y,delta)
