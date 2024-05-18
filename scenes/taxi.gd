extends CharacterBody2D
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D


func keyDown(key: String):
	return Input.is_action_pressed(key)

func toRad(deg: float):
	return (PI / 180) * deg

func CircleRange(num):
	if num < 0:
		num = ceil(abs(num) / 360) * 360 + num
	if num > 360:
		num = (num / 360 - int(num / 360)) * 360
	return num

func changeState(deg, speed):
	var collisionScale = [
		[sprite_2d.scale[0] * 1.5, sprite_2d.scale[0] * 2],
		[sprite_2d.scale[1] * 3.25, sprite_2d.scale[0] * 1.75]
	]
	var config = {
		"right": [deg > 315 or deg < 45, "left", true, 1],
		"left": [deg < 225 and deg > 135, "left", false, 1],
		"up": [deg > 225 and deg < 315, "up", false, 0],
		"down": [deg > 45 and deg < 135, "down", false, 0],
	}
	var forward = speed > 0
	
	for direction in config:
		if config[direction][0]:
			var this = config[direction]
			var flip_h = this[2]
			var anim = this[1]
			
			if speed != 0: anim = "go_" + anim
			else: anim = "stand_" + anim
			sprite_2d.animation = anim
			sprite_2d.flip_h = flip_h
			collision_shape_2d.scale[0] = collisionScale[this[3]][0]
			collision_shape_2d.scale[1] = collisionScale[this[3]][1]
	
			
var angle = 0
var turn = 2.5
var MaxSpeed = 200
var speed = 0
var acceleration = MaxSpeed * 0.02
var deceleration = MaxSpeed * 0.005

func _physics_process(delta):
	
	# x and y axis speed
	var x = cos( toRad(angle) )
	var y = sin( toRad(angle) )
	
	# move forwards and backwards
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
	elif speed < 0:
		if keyDown("Left"):
			angle = move_toward(angle, angle + 45, turn)
		if keyDown("Right"):
			angle = move_toward(angle, angle - 45, turn)
	
	if keyDown("HandBreak"):
		speed = move_toward(speed, 0, deceleration * 10)
	
	# keep the angle between 0 and 360
	if abs(angle) == 360: angle = 0
	
	changeState(CircleRange(angle), speed)
	
	if !keyDown("Up") and !keyDown("Down"):
		speed = move_toward(speed, 0, deceleration)
	
	velocity.x = x * speed * sprite_2d.scale[0]
	velocity.y = y * speed * sprite_2d.scale[1]
	
	move_and_slide()
