extends CharacterBody2D
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

func keyDown(key: String):
	return Input.is_action_pressed(key)
func toRad(deg: float):
	return (PI / 180) * deg
func CircleRange(deg):
	if deg < 0:
		deg = ceil(abs(deg) / 360) * 360 + deg
	if deg > 360:
		deg = (deg / 360 - int(deg / 360)) * 360
	return deg
func WherePoint(deg, accuracy = 0):
	accuracy = abs(accuracy)
	if accuracy > 20: accuracy = 20
	if deg >= 45 + accuracy and deg < 135 - accuracy: return "down"
	if deg >= 135 + accuracy and deg < 225 - accuracy: return "left"
	if deg >= 225 + accuracy and deg < 315 - accuracy: return "up"
	if deg >= 315 + accuracy or deg < 45 - accuracy: return "right"
	return "None"
func SteeringAssist(deg):
	var pointTo = WherePoint(deg)
	var target
	if pointTo == "left": target = 180
	elif pointTo == "up": target = 270
	elif pointTo == "down": target = 90
	elif pointTo == "right" and deg > 180: target = 360
	else: target = 0
	angle = move_toward(angle, target, SteerAssistConfig[1])
func changeState(deg, speed):
	var collisionScale = [
		[sprite_2d.scale[0] * 1.05, sprite_2d.scale[0] * 1.25],
		[sprite_2d.scale[1] * 2.2, sprite_2d.scale[0] * 0.8]
	]
	var config = {
		"right": ["left", true, 1],
		"left": ["left", false, 1],
		"up": ["up", false, 0],
		"down": ["down", false, 0],
	}
	var forward = speed > 0

	var this = config[WherePoint(angle)]
	var flip_h = this[1]
	var anim = this[0]
	if speed != 0 and !keyDown("HandBreak"): anim = "go_" + anim
	elif speed != 0 and keyDown("HandBreak"): anim = "break_" + anim
	else: anim = "stand_" + anim
	sprite_2d.animation = anim
	sprite_2d.flip_h = flip_h
	collision_shape_2d.scale[0] = collisionScale[this[2]][0]
	collision_shape_2d.scale[1] = collisionScale[this[2]][1]

var angle = 0
var turn = 4
var SteerAssistConfig = [true, turn / 3]
var MaxSpeed = 300
var speed = 0
var acceleration = MaxSpeed * 0.01
var deceleration = acceleration * 0.5
var handBreakScale = 8

func _physics_process(delta):
	
	# x and y axis speed
	var x = cos( toRad(angle) )
	var y = sin( toRad(angle) )
	
	# move forwards and backwards
	if !keyDown("HandBreak"):
		if keyDown("Up"):
			speed = move_toward(speed, MaxSpeed, acceleration)
		if keyDown("Down"):
			speed = move_toward(speed, -MaxSpeed / 2, acceleration)
	
	# turn if the car is moving
	if speed > 0:
		if keyDown("Left"):
			angle = move_toward(angle, angle - 45, turn)
		if keyDown("Right"):
			angle = move_toward(angle, angle + 45, turn)
		if !keyDown("Left") and !keyDown("Right") and SteerAssistConfig[0]:
			SteeringAssist(angle)
	elif speed < 0:
		if keyDown("Left"):
			angle = move_toward(angle, angle + 45, turn)
		if keyDown("Right"):
			angle = move_toward(angle, angle - 45, turn)
	
	if keyDown("HandBreak"):
		speed = move_toward(speed, 0, handBreakScale)
	
	# keep the angle between 0 and 360
	
	changeState(angle, speed)
	
	if !keyDown("Up") and !keyDown("Down"):
		speed = move_toward(speed, 0, deceleration)
	
	velocity.x = x * speed * sprite_2d.scale[0]
	velocity.y = y * speed * sprite_2d.scale[1]
	
	angle = CircleRange(angle)
	move_and_slide()
