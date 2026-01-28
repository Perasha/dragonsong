extends Node2D

var chunk_size = 200

var cave_lerp_list = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for cave_node in cave_lerp_list:
		cave_node[0].modulate = cave_node[0].modulate.lerp(cave_node[1],0.1)
	var i = 0
	for cave_node in cave_lerp_list:
		## Check the Alpha channel
		#print(cave_node)
		if cave_node[0].modulate.a <= 0.01:# and cave_node[2] == true:
			cave_node[0].modulate.a = 0.0
			GlobalData.array_swapback(cave_lerp_list,i,"Cave01")
		if cave_node[0].modulate.a >= 0.99:
			cave_node[0].modulate.a = 1.0
			GlobalData.array_swapback(cave_lerp_list,i,"Cave02")
		i += 1

## This is in the context of showing/hiding the COVER of the cave.
func show_cave(cave_node):
	var target_color = cave_node.modulate + Color(0,0,0,1.0)
	#var is_showing = true
	var cave_node_data = [cave_node,target_color]
	## Hypothetically checking the list of actively changing nodes
	## If our node is the exact same node as one in here,
	## that means we have a duplicate and need to remove it.
	for data_entry in cave_lerp_list:
		if data_entry[0] == cave_node:
			return
	cave_lerp_list.append(cave_node_data)

func hide_cave(cave_node):
	var target_color = cave_node.modulate - Color(0,0,0,1.0)
	#var is_showing = false
	var cave_node_data = [cave_node,target_color]
	for data_entry in cave_lerp_list:
		if data_entry[0] == cave_node:
			return
	cave_lerp_list.append(cave_node_data)
	
	#cave_node.modulate = original_color.lerp(target_color,0.1)
