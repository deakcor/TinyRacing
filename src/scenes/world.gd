extends Spatial

onready var im = get_node("draw")
var clear_next:=false

func _ready():
	AirConsole.connect("message_received",self,"_on_AirConsole_message_received")

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


func _on_AirConsole_message_received(device_id:int, data:Dictionary):
	print(device_id,data)
	if data.has("device_rotation"):
		$player_car.turning=data["device_rotation"]
	if data.has("accelerate"):
		$player_car.accelerate=data["accelerate"]
	if data.has("decelerate"):
		$player_car.decelerate=data["decelerate"]
