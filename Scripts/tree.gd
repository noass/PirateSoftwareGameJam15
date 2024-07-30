extends Sprite2D

func _ready():
	material.set_shader_parameter("Speed", randf_range(0.8, 1.2))
