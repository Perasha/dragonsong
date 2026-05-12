extends Node

@onready var objects = get_tree().get_nodes_in_group("object")
@onready var active_chunk = get_node("/root/Main/Map/chunk")

func add_object(location : Vector2,object):
	active_chunk.add_child(object)
	object.global_position = location
	object.modulate = Color(1,1,1,1)

func update_size(object):
	object.get_node("CollisionShape2D").scale = Vector2(object.size,object.size) * 0.5
	object.get_node("sprite").scale = Vector2(object.size,object.size) * 0.5
