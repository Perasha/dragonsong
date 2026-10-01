extends Node2D

@export var chunk_img_test : Image
var chunk_size = Vector2(128,64)

var loaded_chunks = []

@onready var tilemap_terrain = get_node("Tiles")
@onready var object_node = get_node("objects")

var test = 0

var rock_terrain_key = Color(0,0,0,1.0)
var rock_terrain = [] #Array of Vector2i for setting terrain

var start_time = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time = Time.get_ticks_usec()
	generate_terrain(chunk_img_test)
	
	#print("Time elapsed:", Time.get_ticks_usec() - start_time)
	#print(Time.get_unix_time_from_system())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(Time.get_ticks_usec())
	pass

func generate_terrain(chunk_img):
	print(chunk_img.get_width(), ", ", chunk_img.get_height())
	for x in chunk_img.get_width():
		for y in chunk_img.get_height():
			#test += 1
			if chunk_img.get_pixel(x,y) == rock_terrain_key:
				#print("Found")
				rock_terrain.append(Vector2i(x,y))
	#print(rock_terrain)
	tilemap_terrain.set_cells_terrain_connect(rock_terrain, 0, 0, false)
	
