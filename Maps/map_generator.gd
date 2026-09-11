extends Node2D

@export var chunk_img : Image
var test = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Time.get_ticks_usec())
	print(chunk_img)
	print(chunk_img.get_size())
	for x in chunk_img.get_width():
		for y in chunk_img.get_height():
			test += 1
			#print(chunk_img.get_pixel(x,y))
	pass # Replace with function body.
	print(Time.get_ticks_usec())
	#print(Time.get_unix_time_from_system())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(Time.get_ticks_usec())
	pass
