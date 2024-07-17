extends CharacterBody2D

var speed = 300.0

var is_moving = false

func _process(delta):
	DisplayServer.window_set_title("Game | FPS: " + str(Engine.get_frames_per_second()))
	
	if velocity > Vector2.ZERO:
		is_moving = true
	else:
		is_moving = false

func _physics_process(delta):
	var direction = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	velocity = direction * speed
	move_and_slide()
