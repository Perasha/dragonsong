extends Node

## These arrays will let us batch process the different behaviors of each entity
#var herd_entities = []

## And these process the raw individual states of each entity
var idle_entities = []
var moving_entities = []

var dead_entities = []
var grabbed_entities = []

## This array is specifically for navigation; if any entity needs to pathfind, they'll get added to this queue
## Ideally, they'll be processed, then the queue will be emptied.
## Or, actually, if we need to, we can just process one every tick, then rearrange the queue. If it gets bad, that is.
#var nav_queue = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for entity in get_children():
		#if entity.behavior == EntityBehavior.HERD:
		#	insert(entity,herd_entities)
		if entity.thought == EntityBehavior.IDLE:
			insert(entity,idle_entities)
		entity.destination = entity.position
		entity.speed += randi_range(0,50)

## For grabbing; how do we transfer the grabbed entity and the grabber?

func grab_entity(entity):
	print("grabbing")
	if entity.thought != EntityBehavior.DEAD:
		relocate(entity,grabbed_entities,array_search(entity))
		thought_change(entity,EntityBehavior.GRABBED)

func release_entity(entity):
	print("Releasing")
	entity.linear_velocity = entity.grabbing_entity.linear_velocity + Vector2(0,200)
	print(entity.thought)
	if entity.thought != EntityBehavior.DEAD:
		relocate(entity,idle_entities,grabbed_entities)
	entity.grabbing_entity = null

func kill(entity):
	relocate(entity,dead_entities,array_search(entity))
	thought_change(entity,EntityBehavior.DEAD)

func debug_print(entity):
	print("Entity:", entity.name, "; Timer: ", entity.nav_timer, "; Thought:", entity.thought)

## ARRAY MAGIC
func thought_change(entity,thought):
	entity.prev_thought = entity.thought
	entity.thought = thought
func insert(entity,array):
	array.append(entity)
	entity.array_key = array.size() - 1
func relocate(entity,array,prev_array):
	GlobalData.array_swapback(prev_array, entity.array_key)
	if prev_array != [] and entity.array_key != prev_array.size():
		prev_array[entity.array_key].array_key = entity.array_key
	insert(entity,array)
func array_search(entity):
	## Check the entity's thought to see which array it's in
	var found_array = null
	if entity.thought == EntityBehavior.IDLE:
		print("Entity is in IDLE")
		found_array = idle_entities
	elif entity.thought == EntityBehavior.MOVE:
		print("Entity is in MOVE")
		found_array = moving_entities
	elif entity.thought == EntityBehavior.GRABBED:
		print("Entity is in MOVE")
		found_array = grabbed_entities
	return found_array

func _physics_process(delta: float) -> void:
	for entity in idle_entities:
		entity.linear_velocity.x *= 0.75
		entity.nav_timer += 1
	for entity in idle_entities:
		if entity.nav_timer >= entity.nav_timeout:
			EntityBehavior.wander(entity)
			relocate(entity,moving_entities,idle_entities)
			entity.nav_timer = 0
			thought_change(entity,EntityBehavior.MOVE)
	
	for entity in moving_entities:
		EntityBehavior.move_to(entity, entity.destination)
	for entity in moving_entities:
		if entity.position.distance_to(entity.destination) < 100:
			entity.linear_velocity *= 0.15
			relocate(entity,idle_entities,moving_entities)
			thought_change(entity,EntityBehavior.IDLE)
