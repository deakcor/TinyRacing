extends Control


var ready=false
var rotation=0
func _ready():
	AirConsole.connect("is_ready",self,"_on_AirConsole_is_ready")
	AirConsole.connect("device_motion",self,"_on_AirConsole_device_motion")

#func _process(delta):
#	var rotation=min(1,max(-1,stepify(Input.get_accelerometer().x*0.75/5,0.1)))
#	$label.text="test : "+str(rotation)
#	if ready:
#		$AirConsole.message(1, {"device_rotation":rotation})

func _on_AirConsole_device_motion(data:Dictionary):
	
	print(data)
	if data.has("y"):
		var newrotation=-min(1,max(-1,stepify(data.y*0.75/5,0.1)))
		if ready and rotation!=newrotation:
			AirConsole.message(AirConsole.SCREEN, {"device_rotation":rotation})
			rotation=newrotation
			$label.text="test : "+str(rotation)
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

