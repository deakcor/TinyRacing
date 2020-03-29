extends Control


var ready=false
var rotation=0
var state=0
var timer:=0.0


func _ready():
	
	AirConsole.connect("is_ready",self,"_on_AirConsole_is_ready")
	AirConsole.connect("device_motion",self,"_on_AirConsole_device_motion")
	AirConsole.connect("message_received",self,"_on_AirConsole_message_received")


func _process(delta):
	if state==2:
		timer+=delta
		$joy/panel_chrono/label.text=str("%02d:" % int(timer/60))+str(fmod(timer,60)).pad_zeros(2).pad_decimals(2)


func _on_AirConsole_message_received(device_id:int, data:Dictionary):
	if data.has("finish"):
		state=3
		$pause_menu/control/v_box_container/button_resume.visible=false
		$anim_pausemenu.play("open")
		$anim_joy.play_backwards("open")
		
	if data.has("letsgo"):
		state=2
	
	if data.has("ready"):
		ready=true
		$anim_start.play("open")
func _on_AirConsole_device_motion(data:Dictionary):
	
	
	if data.has("y"):
		var newrotation=(-1 if data.x>0 else 1)*min(1,max(-1,stepify(data.y*0.75/5,0.1)))
		#var newrotation=(-1 if data.x>0 else 1)*(1 if data.y>3.0 else ( -1 if data.y<-3.0 else 0))
		if ready and rotation!=newrotation and (abs(rotation-newrotation))<1.1:
			AirConsole.message(AirConsole.SCREEN, {"device_rotation":newrotation})
			rotation=newrotation
	
func _on_AirConsole_is_ready(join_code):
	ready=true
	$anim_start.play("open")


func _on_decelerate_button_pressed():
	if ready:
		AirConsole.message(AirConsole.SCREEN, {"decelerate":true})


func _on_accelerate_button_pressed():
	if ready:
		AirConsole.message(AirConsole.SCREEN, {"accelerate":true})


func _on_decelerate_button_released():
	if ready:
		AirConsole.message(AirConsole.SCREEN, {"decelerate":false})


func _on_accelerate_button_released():
	if ready:
		AirConsole.message(AirConsole.SCREEN, {"accelerate":false})



func _on_TextureButton_pressed():
	if ready and state==2:
		AirConsole.message(AirConsole.SCREEN, {"pause":true})
		$anim_pausemenu.play("open")
		$anim_joy.play_backwards("open")
		state=3
		$audio_select.play()
func _on_Button_pressed():
	if ready:
		AirConsole.message(AirConsole.SCREEN, {"letsgo":true})
		$anim_start.play_backwards("open")
		$anim_joy.play("open")
		$audio_select.play()

func _on_button_resume_pressed():
	if ready:
		AirConsole.message(AirConsole.SCREEN, {"pause":false})
		$anim_pausemenu.play_backwards("open")
		$anim_joy.play("open")
		$audio_select.play()
func _on_button_restart_pressed():
	if ready:
		$pause_menu/control/v_box_container/button_resume.visible=true
		$anim_pausemenu.play_backwards("open")
		AirConsole.message(AirConsole.SCREEN, {"restart":true})
		state=0
		timer=0.0
		$joy/panel_chrono/label.text="STAND BY"
		ready=false
		$audio_select.play()

func _on_button_quit_pressed():
	pass # Replace with function body.


