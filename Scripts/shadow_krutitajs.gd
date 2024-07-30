extends CharacterBody2D

@export var target: CharacterBody2D

@onready var anim_player = $AnimationPlayer
@onready var sprite = $Smoothing2D/Sprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var area_to_hit = $AreaToHit

var blood_particles_preload = preload("res://Scenes/blood_particles.tscn")

var speed = 210.0
var health = 3
var is_hitting = false
var is_dead = false
var knockback_vel = Vector2.ZERO
var knockback_strength = 900.0

func _ready():
	$RoamTimer.wait_time = randf_range(10.0, 15.0)
	pass
	
func _process(delta):
	if !is_hitting and !is_dead:
		anim_player.speed_scale = 3
		if velocity.x > 0 or velocity.x < 0:
			anim_player.play("RUN")
		elif velocity.y > 0:
			anim_player.play("RUN_DOWN")
		elif velocity.y < 0:
			anim_player.play("RUN_UP")
		elif velocity == Vector2.ZERO:
			anim_player.play("IDLE")
		
	if velocity.x < 0 and !is_dead:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true
		
	if area_to_hit.overlaps_body(target) and !is_hitting and !is_dead and target.can_take_damage:
		is_hitting = true
		anim_player.speed_scale = 4
		anim_player.play("HIT")
	elif !area_to_hit.overlaps_body(target) and !is_dead:
		is_hitting = false
	
	if health <= 0 and !is_dead:
		is_dead = true
		$Death.play()
		anim_player.speed_scale = 3
		anim_player.play("DEATH")
		
	#visible = $VisibleOnScreenNotifier2D.is_on_screen()

func _physics_process(delta):
	$HasLineOfSight.look_at(target.global_position)
	
	if !navigation_agent.is_target_reached() and !is_dead:
		velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * speed + knockback_vel
	elif navigation_agent.is_target_reached() and !is_dead:
		velocity = Vector2.ZERO
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

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "HIT" and target.health < target.max_health and !is_dead:
		is_hitting = false
		if !target.can_take_damage: return
		target.iframes()
		target.health += 1
		target.get_node("PlayerHurt").play()
		target.apply_shake()
		target.damage_flash()
		target.hit_count += 1
		var blood_particles = blood_particles_preload.instantiate()
		get_node("/root/World").add_child(blood_particles)
		blood_particles.position = target.position
		blood_particles.emitting = true
		if !blood_particles.is_emitting:
			blood_particles.queue_free()
		if area_to_hit.overlaps_body(target):
			anim_player.play("HIT")
	if anim_name == "DEATH":
		$DeathDespawnTimer.start()

func _on_follow_player_timeout():
	if $PlayerDetectionArea.overlaps_body(target) and $HasLineOfSight.get_collider() == target and target.health < target.max_health and !is_dead and !target.died:
		navigation_agent.target_position = target.global_position
		
func _on_death_despawn_timer_timeout():
	queue_free()
	
func damage_flash():
	$Smoothing2D/Sprite2D.material.set_shader_parameter("flash_modifier", 1)
	$DamageFlashTimer.start()

func _on_damage_flash_timer_timeout():
	$Smoothing2D/Sprite2D.material.set_shader_parameter("flash_modifier", 0)
	
func knockback():
	var direction = target.global_position.direction_to(global_position)
	var explosion_force = direction * knockback_strength
	knockback_vel = explosion_force
