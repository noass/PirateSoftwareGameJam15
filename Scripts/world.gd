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

var fade_out = false
var fade_in = false

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
	
	if Player.location == "World":
		Player.position = Vector2(-4545, 254)
	elif Player.location == "inHouse":
		Player.position = Vector2(-4545, 254)
		Player.scale = Vector2(2.5, 2.5)
		$InHouse/Camera2D.make_current()
		$Player/LightOccluder2D.show()
		$Player/CanvasLayer/UI/HealthBar.hide()
		#$Player/Smoothing2D/SilhouetteSprite.hide()
		$Player/Smoothing2D/Shadow.flip_v = false
		$Player/Smoothing2D/Shadow.position.y -= 32

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
	
	if ($Player/CanvasLayer/FadeTransition.color.a >= 1.0):
		$Player/CanvasLayer/FadeTransition.color.a = 1.0
	if ($Player/CanvasLayer/FadeTransition.color.a <= 0.0):
		$Player/CanvasLayer/FadeTransition.color.a = 0.0
		
	if $Player/CanvasLayer/FadeTransition.color.a < 1.0 and Player.location == "World" and fade_in:
		$Player/CanvasLayer/FadeTransition.color.a += Player.fade_speed * delta
	if $Player/CanvasLayer/FadeTransition.color.a < 1.0 and Player.location == "inHouse" and fade_in:
			$Player/CanvasLayer/FadeTransition.color.a += Player.fade_speed * delta
			
	if $NavigationRegion2D/Solids/House/EnterHouse.overlaps_body(get_node("Player")):
		Player.teleporting = true
		Player.canMove = false
		fade_in = true
		if $Player/CanvasLayer/FadeTransition.color.a >= 1.0 and Player.location == "World": # Go to house
			fade_in = false
			fade_out = true
			Player.location = "inHouse"
			Player.position = Vector2(-4545, 254)
			Player.scale = Vector2(2.5, 2.5)
			$InHouse/Camera2D.make_current()
			$Player/LightOccluder2D.show()
			$Player/CanvasLayer/UI/HealthBar.hide()
			#$Player/Smoothing2D/SilhouetteSprite.hide()
			$Player/Smoothing2D/Shadow.flip_v = false
			$Player/Smoothing2D/Shadow.position.y -= 32
	elif $InHouse/ExitHouse.overlaps_body(get_node("Player")):
		Player.teleporting = true
		Player.canMove = false
		fade_in = true
		if $Player/CanvasLayer/FadeTransition.color.a >= 1.0 and Player.location == "inHouse": # Go to world
			fade_in = false
			fade_out = true
			Player.location = "World"
			Player.position = Vector2(718.835, 410.03)
			Player.scale = Vector2(1.5, 1.5)
			$Player/Camera2D.make_current()
			$Player/LightOccluder2D.hide()
			$Player/CanvasLayer/UI/HealthBar.show()
			#$Player/Smoothing2D/SilhouetteSprite.show()
			$Player/Smoothing2D/Shadow.flip_v = true
			$Player/Smoothing2D/Shadow.position.y += 32
			
	if (fade_out):
		fade_in = false
		$Player/CanvasLayer/FadeTransition.color.a -= Player.fade_speed * delta
		if ($Player/CanvasLayer/FadeTransition.color.a <= 0.0):
			fade_out = false
			Player.teleporting = false
			Player.canMove = true
