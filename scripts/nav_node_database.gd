extends Node

var locations = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_children():
		locations.append(node.position)
