extends Sprite2D

@export var sprite: Sprite2D
@export var shadow_scale = 0.35

func _ready():
	scale.y = shadow_scale
	scale.x = 1
	var texture_height = sprite.texture.get_height()
	position.y = texture_height * shadow_scale / 2 + texture_height / 2
	if sprite.name == "House":
		position.y = ((texture_height * shadow_scale / 2 + texture_height / 2)-7)-(-sprite.offset.y)
		
	texture = sprite.texture
	flip_v = true
	
func _process(delta):
	flip_h = sprite.flip_h
	hframes = sprite.hframes
	frame = sprite.frame
	
