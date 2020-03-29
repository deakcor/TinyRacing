extends Spatial

onready var im = get_node("draw")
var clear_next:=false
var state:=0
var check:=-1
var lap:=0
var timer:=0.0
var timer_string:=""

var gold=100
var silver=105
var bronze=110

var paused=false
var player_device:=1
var devices:=[]
var ghost:=[]
var best_ghost:=[]
var step:=0
var highscores:=[]

func _ready():
	get_tree().paused=false
	AirConsole.connect("message_received",self,"_on_AirConsole_message_received")
	AirConsole.connect("highscores",self,"_on_AirConsole_highscores")
	AirConsole.connect("highscores_stored",self,"_on_AirConsole_highscores_stored")
	AirConsole.connect("device_connected",self,"_on_AirConsole_device_connected")
	AirConsole.connect("device_disconnected",self,"_on_AirConsole_device_disconnected")
	MusicManager.fade(preload("res://assets/music/title.ogg"),1.0,1.0)
	try_ready()
	
func try_ready():
	if AirConsole.ready:
		for id in AirConsole.get_controller_device_ids():
			devices.push_back(id)
		AirConsole.request_highscores("time_trial","5",[str(AirConsole.get_uid(player_device))],["world"])
		if devices.size()>0:
			player_device=devices[0]
			AirConsole.message(player_device,{"ready":true})

func _process(delta):
	if state==2 and !paused:
		timer+=delta
	$camera_cont.translation=$player_car.translation
	$camera_cont.rotation.y=lerp_angle($camera_cont.rotation.y,$player_car.rotation.y,delta)

func check(id:int):
	if id==(check+1)%6:
		check=id
		if id==0:
			
			if lap==2:
				state=3
				
				$player_car.lock=true
				if player_device!=-1:
					timer_string=str("%02d:" % int(timer/60))+str(fmod(timer,60)).pad_zeros(2).pad_decimals(2)
					AirConsole.message(player_device,{"finish":true})
					AirConsole.store_highscore("time_trial", "5",1000000- timer*1000, str(AirConsole.get_uid(player_device)), ghost, timer_string)
				print(timer_string)
				print("ghost data")
				print(ghost)
			else:
				
				lap+=1
				if lap<2:
					
					$lap/label2.text="\n\nLap "+str(lap)+"/2"
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
		$player_car.engine=data["accelerate"]
	if data.has("decelerate"):
		$player_car.decelerate=data["decelerate"]
	if data.has("pause"):
		paused=data["pause"]
		if paused:
			get_tree().paused = paused
		else:
			$starter/animation_player.play("start")
	if data.has("letsgo"):
		start()
	if data.has("restart"):
		Global._changer_scene("world")

#debug
func _input(event):
	if event.is_action_pressed("acceleration"):
		start()

func start():
	if state==0:
		state=1
		
		$tuto/animation_player.play_backwards("open")

func go():
	if state==1:
		state=2
		$player_car.lock=false
		$timer_ghost.start()
		MusicManager.fade(preload("res://assets/music/racing.ogg"),1.0,1.0)
	else:
		get_tree().paused=false
	if player_device!=-1:
		AirConsole.message(player_device,{"letsgo":true})

func _on_AirConsole_highscores(highs:Array):
	print("highscores:")
	print(highs)
	highscores=highs
	print("here")
	var k:=0
	var done:=false
	while k<highscores.size() and !done:
		if highscores[k].uids[0]==AirConsole.get_uid(player_device):
			best_ghost=highscores[k].data
			done=true
		if k==highscores.size()-1:
			best_ghost=highscores[k].data
			done=true
		k+=1
func display_highscore(highscore:Dictionary={}):
	var tmp=preload("res://scenes/hud/highscore_row.tscn")
	var tmp_high=[]
	for k in range(0,highscores.size()):
		
		tmp_high.push_back([highscores[k].ranks.world,highscores[k].nicknames[0],highscores[k].score_string,false])
	if highscore!={}:
		tmp_high.push_back([highscore.ranks.world,highscore.nicknames[0],highscore.score_string,true])
	tmp_high.sort_custom(self,"rank_compare")
	var me_appear=false
	for k in range(0,min(10,tmp_high.size())):
		var tmp2=tmp.instance()
		
		if tmp_high[k][3]:
			me_appear=true
		if k==9 and !me_appear and highscore!={}:
			tmp2.set_row(highscore.ranks.world,highscore.nicknames[0],highscore.score_string,true)
			$hightscore/v_box_container.add_child_below_node($hightscore/v_box_container/new,tmp2)
		else:
			tmp2.set_row(tmp_high[k][0],tmp_high[k][1],tmp_high[k][2],tmp_high[k][3])
			$hightscore/v_box_container.add_child_below_node($hightscore/v_box_container/actual,tmp2)
	$hightscore/animation_player.play("appear")

func rank_compare(a, b):
	if a[0] is String:
		return false
	elif b[0] is String:
		return true
	else:
		return a[0]<b[0]
func _on_AirConsole_highscores_stored(highscore):
	print("my highscore")
	print(highscore)
	if highscore==null:
		if player_device!=-1:
			highscore={"ranks":{"world":"unranked"},"nicknames":[AirConsole.get_nickname(player_device)],"score_string":timer_string}
		else:
			highscore={}
	display_highscore(highscore)

func _on_AirConsole_device_connected(device_id:int):
	if devices.find(device_id)==-1:
		devices.push_back(device_id)
		if player_device==-1:
			player_device=device_id
		AirConsole.request_highscores("time_trial","5",[str(AirConsole.get_uid(player_device))],["world"])

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
		var p=$player_car.translation
		var r=$player_car.rotation
		ghost.push_back({"timer":timer,"position":[p.x,p.y,p.z],"skidding":$player_car.skidding,"rotation":[r.x,r.y,r.z]})
		$timer_ghost.start()
		if best_ghost.size()>step:
			var data=best_ghost[step]
			var old_t=$ghost_car.translation
			var new_t=Vector3(data.position[0],data.position[1],data.position[2])
			$ghost_car.skidding=data.skidding
			var old_r=$ghost_car.rotation
			var new_r=Vector3(data.rotation[0],data.rotation[1],data.rotation[2])
			$tween_ghost.interpolate_property(
			$ghost_car, "translation", 
			old_t, new_t, 0.1,
			Tween.TRANS_LINEAR)
			interpolate_rotation(old_r,new_r, 0.1, 0, 0)
			$tween_ghost.start()
		step+=1

var interpolationStart: Vector3
var interpolationTarget: Vector3
var interpolationWeight: float setget setInterpolationWeight

func interpolate_rotation(init_angle,target_angle: Vector3, duration: float, transType, easeType) -> void:    
	$tween_ghost.remove(self, "interpolationWeight")
	interpolationStart = init_angle
	interpolationTarget = target_angle
	$tween_ghost.interpolate_property(self, "interpolationWeight", 0, 1, duration, transType, easeType)

func  setInterpolationWeight(value: float) -> void:
	interpolationWeight = value
	$ghost_car.rotation = Vector3(lerp_angle(interpolationStart.x, interpolationTarget.x, interpolationWeight),
	lerp_angle(interpolationStart.y, interpolationTarget.y, interpolationWeight),
	lerp_angle(interpolationStart.z, interpolationTarget.z, interpolationWeight))
