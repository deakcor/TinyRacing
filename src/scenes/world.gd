extends Spatial

onready var im = get_node("draw")
var clear_next:=false
var state:=0
var check:=-1
var lap:=0
var timer:=0.0

var gold=100
var silver=105
var bronze=110

func _ready():
	AirConsole.connect("message_received",self,"_on_AirConsole_message_received")
	AirConsole.connect("highscores",self,"_on_AirConsole_highscores")
	AirConsole.request_highscores("0","0",[],[])
func _process(delta):
	if state==2:
		timer+=delta
	$camera_cont.translation=$player_car.translation
	$camera_cont.rotation.y=lerp_angle($camera_cont.rotation.y,$player_car.rotation.y,delta)

func check(id:int):
	if id==(check+1)%6:
		check=id
		print(check)
		if id==0:
			
			if lap==3:
				state=3
				print(str(int(timer/60))+":"+str(stepify(fmod(timer,60),0.01)))
				$player_car.lock=true
			else:
				
				lap+=1
				if lap<3:
					
					$lap/label2.text="\n\nLap "+str(lap)+"/3"
				else:
					$lap/label2.text="\n\nLast lap!"
				$lap/animation_player.play("anim")

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



func _on_AirConsole_message_received(device_id:int, data:Dictionary):
	print(device_id,data)
	if data.has("device_rotation"):
		$player_car.turning=data["device_rotation"]
	if data.has("accelerate"):
		$player_car.accelerate=data["accelerate"]
		start()
	if data.has("decelerate"):
		$player_car.decelerate=data["decelerate"]

func _input(event):
	if event.is_action_pressed("acceleration"):
		start()

func start():
	if state==0:
		state=1
		
		$tuto/animation_player.play_backwards("open")

func go():
	state=2
	$player_car.lock=false

func _on_AirConsole_highscores(highscores):
	print(highscores)


func _on_animation_player_animation_finished(anim_name):
	if state==1:
		$starter/animation_player.play("start")
