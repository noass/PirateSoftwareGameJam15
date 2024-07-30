extends GPUParticles2D

func _on_finished():
	queue_free()

func _on_ready():
	$ArrowDestroySound.play()
