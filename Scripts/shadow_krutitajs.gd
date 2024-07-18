extends CharacterBody2D

@export var target: CharacterBody2D

@onready var anim_player = $AnimationPlayer
@onready var sprite = $Smoothing2D/Sprite2D
@onready var navigation_agent = $NavigationAgent2D

var speed = 210.0

func _ready():
	$RoamTimer.wait_time = randf_range(5.0, 8.0)
	pass

func _physics_process(delta):
	$HasLineOfSight.look_at(target.global_position)
	if $PlayerDetectionArea.overlaps_body(target) and $HasLineOfSight.get_collider() == target:
		navigation_agent.target_position = target.global_position
	
	if !navigation_agent.is_target_reached():
		velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	if velocity != Vector2.ZERO:
		anim_player.play("RUN")
	else:
		anim_player.play("IDLE")
		
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false

	move_and_slide()


func _on_roam_timer_timeout():
	$RoamTimer.wait_time = randf_range(5.0, 8.0)
	if $HasLineOfSight.get_collider() != target and navigation_agent.is_target_reachable():
		navigation_agent.target_position.x = randf_range(48.0, 2417.0)
		navigation_agent.target_position.y = randf_range(39.0, 1731.0)
