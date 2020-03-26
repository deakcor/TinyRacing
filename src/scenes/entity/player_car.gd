extends Car

class_name PlayerCar

func _ready():
	carmodel=get_node("cont")
	high=0.2
	wheel_left=get_node("cont/futuristic_car/wheel_frontRight")
	wheel_right=get_node("cont/futuristic_car/wheel_frontLeft")
	MAX_SPEED=15.0
	ACCELERATION=0.5
func _input(event):
	if event.is_action_pressed("acceleration"):
		accelerate=true
	elif event.is_action_released("acceleration"):
		accelerate=false
	if event.is_action_pressed("deceleration"):
		decelerate=true
	elif event.is_action_released("deceleration"):
		decelerate=false
	elif  event.is_action_pressed("left"):
		turning=1
	elif event.is_action_released("left"):
		if turning==1:
			turning=0
	elif event.is_action_pressed("right"):
		turning=-1
	elif event.is_action_released("right"):
		if turning==-1:
			turning=0
