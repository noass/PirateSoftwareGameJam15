extends CharacterBody2D

@export var target: CharacterBody2D

@onready var anim_player = $AnimationPlayer
@onready var sprite = $Smoothing2D/Sprite2D
@onready var navigation_agent = $NavigationAgent2D

var blood_particles_preload = preload("res://Scenes/blood_particles.tscn")
var projectile_preload = preload("res://Scenes/floating_enemy_projectile.tscn")

var speed = 180.0
var health = 3
var knockback_vel = Vector2.ZERO
var knockback_strength = 900.0
var is_dead = false
var is_shooting = false
var ready_to_shoot = false
var running_away = false

func _ready():
	$RoamTimer.wait_time = randf_range(10.0, 15.0)
	$Smoothing2D/Outline.hframes = sprite.hframes
	$Smoothing2D/Outline.texture = sprite.texture

func _process(delta):
	if !is_dead and !is_shooting:
		anim_player.speed_scale = 2
		if velocity.x > 0 or velocity.x < 0:
			anim_player.play("FLOAT")
		elif running_away:
			anim_player.play("FLOAT")
			
	if velocity.x < 0 and !is_dead:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true
	
	if health <= 0 and !is_dead:
		is_dead = true
		is_shooting = false
		$Death.play()
		$DeathDespawnTimer.start()
		#anim_player.speed_scale = 3
		#anim_player.play("DEATH")
		
	$Smoothing2D/Outline.frame = sprite.frame
	$Smoothing2D/Outline.flip_h = sprite.flip_h
		
	#print("ReadyToShoot: " + str(ready_to_shoot) + ", IsShooting: " + str(is_shooting) + ", SpriteFrame: " + str(sprite.frame) + ", ShootTimer: " + str($ShootTimer.time_left))
	if is_shooting and !running_away and !target.died and !is_dead:
		velocity = Vector2.ZERO
		if target.global_position < global_position:
			sprite.flip_h = false
			$ShootPos.position.x = -8
		elif target.global_position > global_position:
			sprite.flip_h = true
			$ShootPos.position.x = 8
		if sprite.frame >= 11 and sprite.frame <= 11:
			ready_to_shoot = true
			sprite.frame = 11
	if $ShootRange.overlaps_body(target) and $HasLineOfSight.get_collider() == target and !is_shooting and !$RunAwayArea.overlaps_body(target) and !target.died and !is_dead:
		is_shooting = true
		anim_player.speed_scale = 4
		anim_player.play("SHOOTING")
	elif !$ShootRange.overlaps_body(target) and is_shooting and !target.died and !is_dead:
		anim_player.speed_scale = 4
		anim_player.play_backwards("SHOOTING")
		ready_to_shoot = false
	
	if !ready_to_shoot:
		$ShootTimer.start()
		
	if anim_player.current_animation == "SHOOTING" and anim_player.get_playing_speed() < 0 and sprite.frame <= 6 and !target.died:
		is_shooting = false

func _physics_process(delta):
	$HasLineOfSight.look_at(target.global_position)
	
	if !navigation_agent.is_target_reached() and !is_dead and !is_shooting and !$RunAwayArea.overlaps_body(target):
		velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * speed + knockback_vel
	elif navigation_agent.is_target_reached() and !is_dead and !is_shooting:
		velocity = Vector2.ZERO
	elif $RunAwayArea.overlaps_body(target):
		ready_to_shoot = false
		$ShootTimer.stop()
		anim_player.speed_scale = 8
		anim_player.play_backwards("SHOOTING")
		if !is_shooting:
			running_away = true
			var run_away_direction = global_position.direction_to(target.global_position).normalized()
			var run_away_velocity = -run_away_direction * speed + knockback_vel
			velocity = run_away_velocity
			var run_away_target_position = global_position - (run_away_direction * speed)
			navigation_agent.target_position = run_away_target_position
	else:
		running_away = false
	if is_dead:
		$CollisionShape2D.disabled = true
		velocity = Vector2.ZERO

	move_and_slide()
	
	knockback_vel = lerp(knockback_vel, Vector2.ZERO, 7 * delta)
	
func _on_roam_timer_timeout():
	$RoamTimer.wait_time = randf_range(10.0, 15.0)
	if $HasLineOfSight.get_collider() != target and navigation_agent.is_target_reachable() and !is_dead:
		navigation_agent.target_position.x = randf_range(63, 2391)
		navigation_agent.target_position.y = randf_range(50, 1703)

func damage_flash():
	$Smoothing2D/Sprite2D.material.set_shader_parameter("flash_modifier", 1)
	$DamageFlashTimer.start()

func _on_damage_flash_timer_timeout():
	$Smoothing2D/Sprite2D.material.set_shader_parameter("flash_modifier", 0)
	
func knockback():
	var direction = target.global_position.direction_to(global_position)
	var explosion_force = direction * knockback_strength
	knockback_vel = explosion_force

func _on_follow_player_timeout():
	if $DetectionArea.overlaps_body(target) and $HasLineOfSight.get_collider() == target and target.health < target.max_health and !is_dead and !target.died:
		navigation_agent.target_position = target.global_position

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "DEATH":
		$DeathDespawnTimer.start()

func _on_death_despawn_timer_timeout():
	queue_free()

func _on_shoot_timer_timeout():
	var projectile = projectile_preload.instantiate()
	owner.add_child(projectile)
	$Shoot.play()
	projectile.transform = $ShootPos.global_transform
	projectile.look_at(target.global_position)
