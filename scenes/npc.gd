extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D

const speed = 30
var current_state = IDLE

var dir = Vector2.RIGHT
var start_pos

var is_roaming = true
var is_chatting = false

var player
var player_in_chat_zone
enum {
	IDLE,
	NEW_DIR,
	MOVE
}


func _ready():
	randomize()
	start_pos = position
	
func _process(delta):
	if current_state == 0 or current_state == 1:
		$AnimatedSprite2D.play("idle")
	elif current_state == 2 and !is_chatting:
		if dir.x == -1:
			$AnimatedSprite2D.play("left")
		if dir.x == 1:
			$AnimatedSprite2D.play("right")
		if dir.y == -1:
			$AnimatedSprite2D.play("down")
		if dir.y == 1:
			$AnimatedSprite2D.play("up")
	if is_roaming:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				choose([Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN])
			MOVE:
				move(delta)
				
func choose(array):
	array.shuffle()
	return array.front()

func move(delta):
	if !is_chatting:
		position += dir * speed * delta


func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		print("Body entered")
		player = body
		player_in_chat_zone = true


func _on_area_2d_body_exited(body):
	print("Body exited")
	if body.has_method("player"):
		player_in_chat_zone = false


func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])
