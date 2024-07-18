extends Node2D

func _ready():
	get_node("Player/Smoothing2D/Shadow").flip_v = false
	get_node("Player/Smoothing2D/Shadow").position.y -= 32

func _process(delta):
	if $ExitHouse.overlaps_body(get_node("Player")):
		get_tree().change_scene_to_file("res://Scenes/world.tscn")
