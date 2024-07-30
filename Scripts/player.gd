extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Smoothing2D/PlayerSprites/Sprite2D
@onready var silhouette_sprite = $Smoothing2D/PlayerSprites/SilhouetteSprite

var idle_anim = preload("res://Sprites/idle.png")
var run_anim = preload("res://Sprites/Sprirunning_left_and_right.png")
var blood_particles_preload = preload("res://Scenes/blood_particles.tscn")
var arrow_preload = preload("res://Scenes/arrow.tscn")

var speed = 300.0
var canMove = true
var died = false
var death_anim = false
var fade_speed = 2
var location = "inHouse" # inHouse, World
var health = 0.0
var max_health = 10.0
var current_zoom = 1
var max_zoom = 2.5
var min_zoom = 0.5
var zoom_step = 0.1
var hit_count = 0.0
var death_fade_speed = 0.4
var death_timer = false
var spawned = false
var spawned_fade_speed = 0.8
var death_text = "YOU DIED"
var is_shanking = false
var can_take_damage = true
var is_charging_bow = false
var teleporting = false
var invincible = false # CHEAT

var death_quotes = ["[color=red]YOU DIED[/color]", "YOU PERISHED", "GIT GUD", "YOU LOST CONTROL", "DID YOU... DIE?",
					"DEATH IS AVOIDABLE", "MISTAKES WERE MADE", "DID YOU FALL ASLEEP?", "REST IN PIECES", 
					"YOU WEREN'T PREPARED", "GO PLAY ROBLOX", "GO PLAY MINECRAFT",
					"YOU DIED OF DEATH", "TIP: DON'T DIE", "DED", "WOMP WOMP"]
var random_death_text = randi_range(0, death_quotes.size()-1)

var random_camera_shake_strength = 5.0
var camera_shake_fade = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength = 0.0

func _ready():
	silhouette_sprite.texture = sprite.texture
	silhouette_sprite.hframes = sprite.hframes
	$CanvasLayer/UI/DeathScreen/ColorRect.color.a = 1.0
	canMove = false
	spawned = true
	$CanvasLayer/UI/DeathScreen/noise.material.set_shader_parameter("uOpacity", 0.0)

	$DeathSong.volume_db = -9999.9
	
func apply_shake():
	shake_strength = random_camera_shake_strength

func _process(delta):
	DisplayServer.window_set_title("Game | FPS: " + str(Engine.get_frames_per_second()))
	
	if !died:
		if (velocity.x > 0 or velocity.x < 0) and !is_shanking and canMove and !is_charging_bow:
			animation_player.speed_scale = 8
			animation_player.play("RUN")
		elif velocity.y > 0 and !is_shanking and canMove and !is_charging_bow:
			animation_player.speed_scale = 5
			animation_player.play("RUN_DOWN")
		elif velocity.y < 0 and !is_shanking and canMove and !is_charging_bow:
			animation_player.speed_scale = 5
			animation_player.play("RUN_UP")
		elif velocity == Vector2.ZERO and !is_charging_bow and !is_shanking:
			animation_player.speed_scale = 2
			animation_player.play("IDLE")
		
	if velocity.x < 0:
		sprite.flip_h = true
		$AttackRange.position.x = -15.5
	elif velocity.x > 0:
		sprite.flip_h = false
		$AttackRange.position.x = 15.5
	
	silhouette_sprite.flip_h = sprite.flip_h
	silhouette_sprite.frame = sprite.frame
		
	if Input.is_action_just_pressed("M_WHEELUP") and current_zoom <= max_zoom:
		current_zoom += zoom_step
	if Input.is_action_just_pressed("M_WHEELDOWN") and current_zoom >= min_zoom:
		current_zoom -= zoom_step
	$Camera2D.zoom = Vector2(current_zoom, current_zoom)
	
	if health >= max_health: health = max_health
	if health <= 0.0: health = 0
	if hit_count >= max_health: hit_count = max_health
	
	var health_give_speed = 10 * delta
	$CanvasLayer/UI/HealthBar/Effect.material.set_shader_parameter("progress", lerpf($CanvasLayer/UI/HealthBar/Effect.material.get_shader_parameter("progress"), health/10.0, health_give_speed))
	$CanvasLayer/UI/HealthBar/HealthText.text = str(health) + "/" + str(max_health)
	
	$CanvasLayer/Vignette.material.set_shader_parameter("inner_radius", (health/1000.0)*health)
	$CanvasLayer/Vignette.material.set_shader_parameter("dither_strength", (hit_count/100.0)+0.001*hit_count)
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, camera_shake_fade * delta)
		$Camera2D.offset = randomOffset()
		
	if health >= max_health and !invincible:
		death(delta)
		$CollisionShape2D.disabled = true
		#var death_song_tween = get_tree().create_tween()
		#death_song_tween.tween_property($DeathSong, "volume_db", -20, 0.25).set_trans(Tween.TRANS_LINEAR)
		
	if spawned:
		$CanvasLayer/UI/DeathScreen/ColorRect.color.a -= spawned_fade_speed * delta
		if $CanvasLayer/UI/DeathScreen/ColorRect.color.a <= 0.0:
			spawned = false
			canMove = true
			
	if Input.is_action_just_pressed("LEFT_MOUSE") and !is_shanking and !spawned and !died and !is_charging_bow and !teleporting:
		is_shanking = true
		canMove = false
		$Shank.play()
		animation_player.speed_scale = 7
		animation_player.play("SHANK")
		for body in $AttackRange.get_overlapping_bodies():
			if body.is_in_group("enemy"):
				body.health -= 1
				body.knockback()
				body.damage_flash()
				body.get_node("Hurt").play()
				var blood_particles = blood_particles_preload.instantiate()
				get_node("/root/World").add_child(blood_particles)
				blood_particles.position = body.position
				blood_particles.emitting = true
				if !blood_particles.is_emitting:
					blood_particles.queue_free()
					
	if Input.is_action_pressed("RIGHT_MOUSE") and !is_charging_bow and !died and !is_shanking:
		is_charging_bow = true
		animation_player.stop()
		sprite.frame = 36
		$Smoothing2D/PlayerSprites/BowOnly.show()
		$Smoothing2D/PlayerSprites/OtherHand.show()
	elif Input.is_action_just_released("RIGHT_MOUSE") and !died:
		if $Smoothing2D/PlayerSprites/BowOnly.frame == 2:
			$Smoothing2D/PlayerSprites/BowOnly.frame = 3
			var arrow = arrow_preload.instantiate()
			owner.add_child(arrow)
			$BowShoot.play()
			arrow.transform = $Smoothing2D/PlayerSprites/BowOnly/ArrowSpawnPoint.global_transform
		await get_tree().create_timer(0.2).timeout
		is_charging_bow = false
		$Smoothing2D/PlayerSprites/BowOnly.hide()
		$Smoothing2D/PlayerSprites/OtherHand.hide()
		canMove = true
		
	if is_charging_bow and !teleporting:
		var target_pos = global_position.lerp(get_global_mouse_position(), 50 * delta)
		$Camera2D.global_position = $Camera2D.global_position.lerp(target_pos, 7 * delta)
		canMove = false
		if $Smoothing2D/PlayerSprites/BowOnly.frame < 2:
			$Smoothing2D/PlayerSprites/BowOnly/AnimationPlayer.play("CHARGING_BOW")
		else:
			$Smoothing2D/PlayerSprites/BowOnly/AnimationPlayer.stop(true)
		$Smoothing2D/PlayerSprites/BowOnly.look_at(get_global_mouse_position())
		$Smoothing2D/PlayerSprites/OtherHand.rotation = $Smoothing2D/PlayerSprites/BowOnly.rotation
		var other_side_offset_x = 2
		if get_global_mouse_position() < global_position:
			sprite.flip_h = true
			$Smoothing2D/PlayerSprites/BowOnly.flip_v = true
			$Smoothing2D/PlayerSprites/OtherHand.flip_v = true
			$Smoothing2D/PlayerSprites/BowOnly.position.x = 2
			$Smoothing2D/PlayerSprites/OtherHand.position.x = 2
		elif get_global_mouse_position() > global_position:
			sprite.flip_h = false
			$Smoothing2D/PlayerSprites/BowOnly.flip_v = false
			$Smoothing2D/PlayerSprites/OtherHand.flip_v = false
			$Smoothing2D/PlayerSprites/BowOnly.position.x = -2
			$Smoothing2D/PlayerSprites/OtherHand.position.x = -2
	elif !is_charging_bow and !teleporting:
		var target_pos = global_position
		$Camera2D.global_position = $Camera2D.global_position.lerp(target_pos, 7 * delta)
		$Smoothing2D/PlayerSprites/BowOnly.frame = 0
	
	$Smoothing2D/PlayerSprites/BowOnly/ArrowSpawnPoint.position = Vector2($Smoothing2D/PlayerSprites/BowOnly.position.x + 23.0, $Smoothing2D/PlayerSprites/BowOnly.position.x - 0.5)
	
func randomOffset():
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _physics_process(delta):
	var direction = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	if canMove:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
func death(dt):
	if !death_timer:
		#$DeathSong.play()
		$PlayerDeath.play()
		$CanvasLayer/UI/DeathScreen/Timer.start()
		death_timer = true
	canMove = false
	died = true
	is_charging_bow = false
	$Smoothing2D/PlayerSprites/BowOnly.hide()
	$Smoothing2D/PlayerSprites/OtherHand.hide()
	if !death_anim:
		generate_death_quote()
		animation_player.speed_scale = 2
		animation_player.play("DEATH")
		death_anim = true
	$CanvasLayer/UI/DeathScreen.show()
	if $CanvasLayer/UI/DeathScreen/Timer.time_left <= 0.0 and $CanvasLayer/UI/DeathScreen/ColorRect.color.a <= 1.0:
		$CanvasLayer/UI/DeathScreen/DeathText.modulate.a += death_fade_speed * dt
		$CanvasLayer/UI/DeathScreen/Timer.stop()
		$CanvasLayer/UI/DeathScreen/ColorRect.color.a += death_fade_speed * dt
		$CanvasLayer/UI/DeathScreen/noise.material.set_shader_parameter("uOpacity", $CanvasLayer/UI/DeathScreen/ColorRect.color.a/3)
	if $CanvasLayer/UI/DeathScreen/ColorRect.color.a >= 1.0:
		$CanvasLayer/UI/DeathScreen/RestartText.modulate.a += death_fade_speed * dt
		if Input.is_action_just_pressed("R"):
			get_tree().reload_current_scene()
		
func generate_death_quote():
	$CanvasLayer/UI/DeathScreen/DeathText.text = str("[center]"+death_quotes[random_death_text]+"[/center]")

func damage_flash():
	sprite.material.set_shader_parameter("flash_modifier", 1)
	sprite.z_index = silhouette_sprite.z_index + 1
	$DamageFlashTimer.start()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "SHANK":
		canMove = true
		is_shanking = false

func _on_damage_flash_timer_timeout():
	sprite.material.set_shader_parameter("flash_modifier", 0)
	sprite.z_index = 0
	
func iframes():
	can_take_damage = false
	await get_tree().create_timer(0.5).timeout
	can_take_damage = true
