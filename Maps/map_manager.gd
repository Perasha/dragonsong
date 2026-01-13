extends Node2D

var chunk_size = 200
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_cave(cave_node):
	cave_node.show()

func hide_cave(cave_node):
	cave_node.hide()
