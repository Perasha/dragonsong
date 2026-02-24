extends Node

@onready var object_manager = get_node("/root/Main/ObjectManager")
var corpse = preload("res://entities/corpse_generic.tscn")

var species_groups = {
	"Bison" : []
}

var entities = []
var moving_entities = []

var presence_entities = []
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
		
		if entity.presence:
			presence_entities.append(entity)
	print(presence_entities)

## ARRAY MAGIC
func insert(entity,array):
	array.append(entity)
	entity.array_key = array.size() - 1
func relocate(entity,array,prev_array,debug_info):
	GlobalData.array_swapback(prev_array, entity.array_key,debug_info)
	if prev_array != [] and entity.array_key != prev_array.size():
		## Yeah this is a mouthful;
		## The entity in the array (position of the recently-removed entity),
		## Its array key will now be the key of the recently-removed entity.
		prev_array[entity.array_key].array_key = entity.array_key
	insert(entity,array)

func _physics_process(delta: float) -> void:
		
	## Processing Dead Entities	
	for entity in dead_entities:
		#print("Processing Dead Entities")
		#print("Entity: ", entity.name, ", ", entity.array_key)
		#print(entities)
		#print(entities[entity.array_key])
		GlobalData.array_swapback(entities,entity.array_key,"DeadEntities01")
		## Yeah this is a mouthful;
		## The entity in the array (position of the recently-removed entity),
		## Its array key will now be the key of the recently-removed entity.
		if entities != [] and entity.array_key != entities.size():
			entities[entity.array_key].array_key = entity.array_key
		var new_corpse = corpse.instantiate()
		object_manager.add_child(new_corpse)
		new_corpse.position = entity.position
		new_corpse.name = entity.name + " Corpse"
		new_corpse.sprite.texture = entity.sprite.texture
		new_corpse.sprite.region_rect = entity.sprite.region_rect
		entity.queue_free()
	dead_entities = []
	
	## Process entities moving to a destination
	
	## First, see which entities are moving and grounded.
	for entity in entities:
		if entity.is_grounded:
			entity.gravity_scale = 0.0
			if entity.is_moving:
				moving_entities.append(entity)
		else:
			entity.gravity_scale = 2.0
	
	## Then, actually move those entities.
	for entity in moving_entities:
		entity.gravity_scale = 0.0
		entity.move_to(entity.destination)
	
	## Finally, for each entity, check if they're at their destination.
	## If they are, they're no longer moving.
	for entity in moving_entities:
		if entity.position.distance_to(entity.destination) < 100:
			entity.linear_velocity *= 0.15
			entity.is_moving = false
	
	moving_entities = []
	
	## Process our Presence entities
	var i = 0
	for entity in presence_entities:
		if not is_instance_valid(entity):
			GlobalData.array_swapback(presence_entities,i,"presence loop")
		i += 1
	for entity in presence_entities:
		entity.PresenceBehavior.execute(entity)
