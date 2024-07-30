extends Sprite2D

@export var arrow_speed = 350.0

var blood_particles_preload = preload("res://Scenes/blood_particles.tscn")
var arrow_destroy_particles_preload = preload("res://Scenes/arrow_destroy_particles.tscn")

func _physics_process(delta):
	position += transform.x * arrow_speed * delta

func _on_hit_detect_body_entered(body):
	if body.is_in_group("enemy"):
		body.health -= 2
		body.knockback()
		body.damage_flash()
		body.get_node("Hurt").play()
		var blood_particles = blood_particles_preload.instantiate()
		get_node("/root/World").add_child(blood_particles)
		blood_particles.position = body.position
		blood_particles.emitting = true
		if !blood_particles.is_emitting:
			blood_particles.queue_free()
		queue_free()
	elif body.name != "Player":
		var arrow_destroy_particles = arrow_destroy_particles_preload.instantiate()
		get_node("/root/World").add_child(arrow_destroy_particles)
		arrow_destroy_particles.position = position
		arrow_destroy_particles.rotation = rotation
		arrow_destroy_particles.emitting = true
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
