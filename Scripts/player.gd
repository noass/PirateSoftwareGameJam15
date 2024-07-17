extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Smoothing2D/Sprite2D

var idle_anim = preload("res://Sprites/idle.png")
var run_anim = preload("res://Sprites/Sprirunning_left_and_right.png")

var speed = 300.0

func _process(delta):
	DisplayServer.window_set_title("Game | FPS: " + str(Engine.get_frames_per_second()))
		
	if velocity.x > 0 or velocity.x < 0:
		animation_player.speed_scale = 8
		animation_player.play("RUN")
	elif velocity.y > 0:
		animation_player.speed_scale = 5
		animation_player.play("RUN_DOWN")
	elif velocity.y < 0:
		animation_player.speed_scale = 5
		animation_player.play("RUN_UP")
	elif velocity == Vector2.ZERO:
		animation_player.speed_scale = 2
		animation_player.play("IDLE")
		
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

func _physics_process(delta):
	var direction = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	velocity = direction * speed
	move_and_slide()
