extends Node

## Note 5-26-2026
## Making this multiplayer-compatible means that we have to somehow make this...
## client-side maybe?
## Idk, that's a mess, we'll figure that out years from now
## How hard was it, future me?

var max_pile_size = 40

@onready var dragon_node = get_node("%dragon")
#@onready var objects = get_tree().get_nodes_in_group("object")
@onready var active_chunk = get_node("/root/Main/Map/chunk")

var full_outline = Color(1,1,1,0.6)
var no_outline = Color(1,1,1,0)

func _ready():	
	dragon_node.get_node("InteractArea").body_entered.connect(_on_dragon_interact_body_entered)
	dragon_node.get_node("InteractArea").body_exited.connect(_on_dragon_interact_body_exited)
	for object in get_tree().get_nodes_in_group("object"):
		#print(object.get_node("sprite").material.get_shader_parameter("line_color"))
		object.get_node("sprite").material.set_shader_parameter("line_color",no_outline)
	
	for item_pile in get_tree().get_nodes_in_group("item_pile"):
		pile_update_size(item_pile)

func _process(delta: float) -> void:
	#for object in objects:
	#	if object.is_highlighted == true:
	#		pass
	pass

func add_object(location : Vector2,object):
	active_chunk.get_node("objects").add_child(object)
	object.global_position = location
	object.modulate = Color(1,1,1,1)
	highlight(object,false)
	#object.get_node("sprite").material.set_shader_parameter("line_color",no_outline)

func pile_update_size(object):
	var object_sprite = object.get_node("sprite")
	if object.size <= max_pile_size:
		object_sprite.region_rect.size.y = object.size + 1
		object_sprite.offset.y = -object.size

func highlight(object,is_active):
	if is_active:
		object.get_node("sprite").material.set_shader_parameter("line_color",full_outline)
	else:
		object.get_node("sprite").material.set_shader_parameter("line_color",no_outline)

func _on_dragon_interact_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.add_to_group("select_choice")
		if not dragon_node.interact_field.highlighted_object == null:
			highlight(dragon_node.interact_field.highlighted_object,false)
		dragon_node.interact_field.highlighted_object = body
		highlight(body,true)

func _on_dragon_interact_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.remove_from_group("select_choice")
		if dragon_node.interact_field.highlighted_object == body:
			highlight(body,false)
			dragon_node.interact_field.highlighted_object = null
