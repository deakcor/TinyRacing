extends KinematicBody

class_name Car

const MAX_SPEED:=20.0
const MAX_SPEED_BACK:=-5.0
const ACCELERATION:=1.0
const DECELERATION_FREIN:=1.0
const DECELERATION:=0.5
const TURN_SPEED:=20.0
const G:=10.0

var accelerate:=false
var decelerate:=false
var dir:=Vector3.FORWARD
var realdir:=translation
var motion:=Vector3.ZERO
var turning:=0

func _physics_process(delta):
	var speed=(motion*Vector3(1,0,1)).length()
	if (motion.normalized()-dir.normalized()).length()>1:
		speed=-speed
		print("nop")
	else:
		
		if decelerate:
			print("derapage")
		else:
			print("nop")
	var old_translation=translation
	if accelerate:
		speed=lerp(speed,MAX_SPEED,delta*ACCELERATION)
	elif decelerate:
		speed=lerp(speed,MAX_SPEED_BACK,delta*DECELERATION_FREIN)
	else:
		speed=lerp(speed,0,delta*DECELERATION)
	if turning!=0:
		dir=dir.rotated(Vector3.UP,PI/4*delta*
		(TURN_SPEED/(abs(speed)) if abs(speed)>5.0 else speed)
		*
		(1 if turning==1 else -1))
	motion.x=speed*dir.x
	motion.z=speed*dir.z
	motion=move_and_slide(motion,Vector3.UP)
	if !is_on_floor():
		motion.y-=G*delta
	realdir=(translation-old_translation)
	animation()
func animation():
#	if realdir.length()>0.1:
#		realdir=realdir.normalized()
	$MeshInstance.look_at($MeshInstance.global_transform.origin+dir,Vector3.UP)
	$CollisionShape.look_at($CollisionShape.global_transform.origin+dir,Vector3.UP)
	
#	var space_state := get_world().direct_space_state
#	var result := space_state.intersect_ray(global_transform.origin, global_transform.origin+Vector3.DOWN*10, [self])
#	if result:
#		print(result.normal)
#		$MeshInstance.rotation.x=PI/4
