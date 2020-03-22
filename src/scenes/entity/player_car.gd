extends Car


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
		turning=2
	elif event.is_action_released("right"):
		if turning==2:
			turning=0
