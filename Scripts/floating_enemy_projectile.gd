extends Sprite2D

@export var projectile_speed = 500

var blood_particles_preload = preload("res://Scenes/blood_particles.tscn")

func _physics_process(delta):
	position += transform.x * projectile_speed * delta

func _on_hit_detect_body_entered(body):
	if body.name == "Player":
		body.health += 2
		body.damage_flash()
		body.get_node("PlayerHurt").play()
		var blood_particles = blood_particles_preload.instantiate()
		get_node("/root/World").add_child(blood_particles)
		blood_particles.position = body.position
		blood_particles.emitting = true
		if !blood_particles.is_emitting:
			blood_particles.queue_free()
		queue_free()
	else:
		var blood_particles = blood_particles_preload.instantiate()
		get_node("/root/World").add_child(blood_particles)
		blood_particles.get_node("Hit").play()
		blood_particles.global_position = global_position
		blood_particles.emitting = true
		if !blood_particles.is_emitting:
			blood_particles.queue_free()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
