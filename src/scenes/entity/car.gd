extends KinematicBody

class_name Car

var MAX_SPEED:=20.0
var MAX_SPEED_BACK:=-5.0
var ACCELERATION:=1.0
var DECELERATION_FREIN:=0.7
var DECELERATION:=0.5
var TURN_SPEED:=20.0
const G:=10.0

var high:=1.0
var accelerate:=false
var decelerate:=false
var flying:=false
var dir:=Vector3.FORWARD
var motion:=Vector3.ZERO
var turning:=0.0
var floor_normal:=Vector3.ONE
var slow_down:=1.0
var lock=true
var skidding=false
var engine=false

var carmodel
var wheel_left
var wheel_right
var wheel_left_offset=0
var wheel_right_offset=-PI



func _physics_process(delta):
	var speed=(motion*Vector3(1,0,1)).length()
	var derapage:Vector3
	var derapage2:Vector3
	if (motion.normalized()-dir.normalized()).length()>1:
		speed=-speed
	else:
		
		if decelerate and !flying:
			derapage=$pos_wheel1.global_transform.origin
			derapage2=$pos_wheel2.global_transform.origin
			skidding=true
		else:
			skidding=false
	if  !flying and !lock:
		if decelerate:
			speed=lerp(speed,MAX_SPEED_BACK*slow_down,delta*DECELERATION_FREIN/slow_down)
		elif accelerate:
			speed=lerp(speed,MAX_SPEED*slow_down,delta*ACCELERATION/slow_down)
		
		else:
			speed=lerp(speed,0,delta*DECELERATION)
		if turning!=0:
			dir=dir.rotated(Vector3.UP,PI/4*delta*
			(TURN_SPEED/(abs(speed*(1 if decelerate else 2))) if abs(speed)>5.0 else speed/2)
			*
			(turning))
	if lock:
		speed=lerp(speed,0,delta*DECELERATION_FREIN/slow_down)
	motion.x=speed*dir.x
	motion.z=speed*dir.z
	
	motion=move_and_slide(motion,Vector3.UP)
	if get_parent().has_method("update_draw"):
		if derapage!=Vector3() and speed>10:
			
			get_parent().update_draw(derapage, $pos_wheel1.global_transform.origin)
			get_parent().update_draw(derapage2, $pos_wheel2.global_transform.origin)
		else:
			get_parent().clear_next_draw()
	if !is_on_floor():
		motion.y-=G*delta
	animation()
	if engine:
		print(motion.length())
		$audio_engine.pitch_scale=lerp($audio_engine.pitch_scale,2+2*motion.length()/MAX_SPEED*slow_down,delta*ACCELERATION/slow_down)
	else:
		$audio_engine.pitch_scale=lerp($audio_engine.pitch_scale,1*slow_down,delta*DECELERATION/slow_down)
func animation():
#	if carmodel!=null:
#		carmodel.look_at(carmodel.global_transform.origin+realdir,Vector3.UP)
#	$CollisionShape.look_at($CollisionShape.global_transform.origin+realdir,Vector3.UP)

	var realdir=dir
	look_at(global_transform.origin+realdir,Vector3.UP)
	var space_state := get_world().direct_space_state
	var result := space_state.intersect_ray(global_transform.origin, global_transform.origin+Vector3.DOWN*(high+1.0), [self])
	if result:
		flying=false
		floor_normal=result.normal+Vector3(1,0,1)
		if result.collider is StaticBody:
			slow_down=0.1
		else:
			slow_down=1.0
	else:
		flying=true
	
	if wheel_right!=null:
		wheel_right.rotation.y=turning*25*PI/180+wheel_right_offset
	if wheel_left!=null:
		wheel_left.rotation.y=turning*25*PI/180+wheel_left_offset
