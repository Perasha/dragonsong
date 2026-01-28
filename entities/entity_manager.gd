extends Node

@onready var object_manager = get_node("/root/Main/ObjectManager")
var corpse = preload("res://entities/corpse_generic.tscn")

var species_groups = {
	"Bison" : []
}

var entities = []
var moving_entities = []
#var move_queue = []

## This processes any entities that die
var dead_entities = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for entity in get_children():
		insert(entity,entities)
		if not species_groups.has(entity.species):
			species_groups[entity.species] = []
		species_groups[entity.species].append(entity)
		#if entity.species == "Bison":
		#	species_groups["Bison"].append(entity)
		#entities.append(entity)

## ARRAY MAGIC
#func thought_change(entity,thought):
	#entity.prev_thought = entity.thought
	#entity.thought = thought
func insert(entity,array):
	array.append(entity)
	entity.array_key = array.size() - 1
	#print("~~~~~~~~~~~INSERT START")
	#print("Entity: ", entity)
	#print("Entity's new key: ", entity.array_key)
	#print("Entity located in the array: ", array[entity.array_key])
	#print("The Array: ", array)
	#print("~~~~~~~~~~~INSERT END")
func relocate(entity,array,prev_array,debug_info):
	GlobalData.array_swapback(prev_array, entity.array_key,debug_info)
	if prev_array != [] and entity.array_key != prev_array.size():
		prev_array[entity.array_key].array_key = entity.array_key
	insert(entity,array)

func _physics_process(delta: float) -> void:
		
	## Processing Dead Entities	
	for entity in dead_entities:
		GlobalData.array_swapback(entities,entity.array_key,"DeadEntities01")
		var new_corpse = corpse.instantiate()
		object_manager.add_child(new_corpse)
		new_corpse.position = entity.position
		new_corpse.name = entity.name + " Corpse"
		entity.queue_free()
	dead_entities = []
	
	#print(entities)
	## Process entities moving to a destination
	
	## First, see which entities are moving and grounded.
	for entity in entities:
		if entity.is_moving and entity.is_grounded:
			moving_entities.append(entity)
	
	## Then, actually move those entities.
	for entity in moving_entities:
		entity.move_to(entity.destination)
	
	## Finally, for each entity, check if they're at their destination.
	## If they are, they're no longer moving.
	for entity in moving_entities:
		#print(moving_entities)
		if entity.position.distance_to(entity.destination) < 100:
			entity.linear_velocity *= 0.15
			entity.is_moving = false
			#print(entity, " has stopped moving.")
	
	moving_entities = []
