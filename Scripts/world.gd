extends Node2D

@export var fog: Sprite2D
@export var fogWidth = 2500
@export var fogHeight = 1800
@export var LightTexture: CompressedTexture2D
@export var lightWidth = 300
@export var lightHeight = 300
@export var Player: CharacterBody2D
@export var debounce_time = 0.01

var time_since_last_fog_update = 0.0

var fogImage: Image
var lightImage: Image
var light_offset: Vector2
var fogTexture: ImageTexture
var light_rect: Rect2

func _ready():
	lightImage = LightTexture.get_image()
	lightImage.resize(lightWidth, lightHeight)

	light_offset = Vector2(lightWidth/2, lightHeight/2)

	fogImage = Image.create(fogWidth, fogHeight, false, Image.FORMAT_RGBA8)
	fogImage.fill(Color.BLACK)
	fogTexture = ImageTexture.create_from_image(fogImage)
	fog.texture = fogTexture

	light_rect = Rect2(Vector2.ZERO, lightImage.get_size())

	update_fog(Player.position)

func update_fog(pos):
	fogImage.blend_rect(lightImage, light_rect, pos - light_offset)
	fogTexture.update(fogImage)
	
func _process(delta):
	time_since_last_fog_update += delta
	if (time_since_last_fog_update >= debounce_time):
		var player_input = Player.velocity
		if player_input.length() > 0:
			time_since_last_fog_update = 0.0
			update_fog(Player.position)
	
	if $NavigationRegion2D/Solids/House/EnterHouse.overlaps_body(get_node("Player")):
		get_tree().change_scene_to_file("res://Scenes/in_house.tscn")
