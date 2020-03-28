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
		$joy/label.text=str(int(timer/60))+":"+str(stepify(fmod(timer,60),0.01))


func _on_AirConsole_message_received(device_id:int, data:Dictionary):
	if data.has("finish"):
		state=3
		
	if data.has("letsgo"):
		state=2
func _on_AirConsole_device_motion(data:Dictionary):
	
	print(data)
	if data.has("y"):
		var newrotation=-min(1,max(-1,stepify(data.y*0.75/5,0.1)))
		if ready and rotation!=newrotation:
			AirConsole.message(AirConsole.SCREEN, {"device_rotation":rotation})
			rotation=newrotation
	
func _on_AirConsole_is_ready(join_code):
	ready=true


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

