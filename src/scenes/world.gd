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

var player_device:=1
var devices:=[]
var ghost:=[]
var best_ghost:=[]
var step:=0
var highscores:=[]

func _ready():
	AirConsole.connect("message_received",self,"_on_AirConsole_message_received")
	AirConsole.connect("highscores",self,"_on_AirConsole_highscores")
	AirConsole.connect("highscores_stored",self,"_on_AirConsole_highscores_stored")
	AirConsole.connect("device_connected",self,"_on_AirConsole_device_connected")
	AirConsole.connect("device_disconnected",self,"_on_AirConsole_device_disconnected")
	AirConsole.request_highscores("time_trial","0",[],[])
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
			
			if lap==0:
				state=3
				print(str(int(timer/60))+":"+str(stepify(fmod(timer,60),0.01)))
				$player_car.lock=true
				if player_device!=-1:
					var time=timer
					var ghost=ghost
					AirConsole.message(player_device,{"finish":true})
					AirConsole.store_highscore("time_trial", "0", time, str(AirConsole.get_uid(player_device)), ghost, str(int(time/60))+":"+str(stepify(fmod(time,60),0.01)))
				print(timer)
				print(ghost)
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
	$timer_ghost.start()
	if player_device!=-1:
		AirConsole.message(player_device,{"letsgo":true})

func _on_AirConsole_highscores(highscores):
	print(highscores)
	self.highscores=highscores
	var k:=0
	var done:=false
	while k<highscores.size() and !done:
		if highscores[k].uids[0]==AirConsole.get_uid(player_device):
			ghost=highscores[k].data
			done=true
		if k==highscores.size()-1:
			ghost=highscores[k].data
			done=true
		k+=1
func display_highscore(highscore:Dictionary):
	var tmp=preload("res://scenes/hud/highscore_row.tscn")
	var tmp_high=[]
	for k in range(0,highscores.size()):
		
		tmp_high.push_back([highscores[k].ranks.world,highscores[k].nicknames[0],highscores[k].score_string,false])
		
	tmp_high.push_back([highscore.ranks.world,highscore.nicknames[0],highscore.score_string,true])
	tmp_high.sort_custom(self,"rank_compare")
	var me_appear=false
	for k in range(0,min(10,tmp_high.size())):
		var tmp2=tmp.instance()
		
		if tmp_high[k][3]:
			me_appear=true
		if k==9 and !me_appear:
			tmp2.set_row(highscore.ranks.world,highscore.nicknames[0],highscore.score_string,true)
		else:
			tmp2.set_row(tmp_high[k][0],tmp_high[k][1],tmp_high[k][2],tmp_high[k][3])
		$hightscore/v_box_container.add_child(tmp2)
	$hightscore/animation_player.play("appear")

func rank_compare(a, b):
	return a[0]<b[0]
func _on_AirConsole_highscores_stored(highscore):
	display_highscore(highscore)

func _on_AirConsole_device_connected(device_id:int):
	if devices.find(device_id)==-1:
		devices.push_back(device_id)
		if player_device==-1:
			player_device=device_id

func _on_AirConsole_device_disconnected(device_id:int):
	var id=devices.find(device_id)
	if id!=-1:
		devices.remove(id)
		player_device=-1

func _on_animation_player_animation_finished(anim_name):
	if state==1:
		$starter/animation_player.play("start")


func _on_timer_ghost_timeout():
	if state==2:
		ghost.push_back({"timer":timer,"position":$player_car.translation,"skidding":$player_car.skidding,"rotation":$player_car.rotation})
		$timer_ghost.start()
		if best_ghost.size()>step:
			var data=best_ghost[step]
			$ghost_car.translation=data.position
			$ghost_car.skidding=data.skidding
			$ghost_car.rotation=data.rotation
		step+=1
		
