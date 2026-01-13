extends Node

## These arrays will let us batch process the different behaviors of each entity
var herd_entities = []
var idle_entities = []
var moving_entities = []
var dead_entities = []

## This array is specifically for navigation; if any entity needs to pathfind, they'll get added to this queue
## Ideally, they'll be processed, then the queue will be emptied.
## Or, actually, if we need to, we can just process one every tick, then rearrange the queue. If it gets bad, that is
var nav_queue = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for entity in get_children():
		if entity.behavior == "Herd":
			herd_entities.append(entity)
		if entity.thought == EntityBehavior.IDLE:
			idle_entities.append(entity)
		entity.destination = entity.position
		print(entity.destination)
		entity.speed += randi_range(0,50)


func _physics_process(delta: float) -> void:
	var i = 0
	for entity in idle_entities:
		entity.linear_velocity *= 0.75
		entity.nav_timer += 1
		if entity.nav_timer >= entity.nav_timeout:
			EntityBehavior.wander(entity)
			moving_entities.append(entity)
			array_swapback(idle_entities, i)
			entity.nav_timer = 0
		i += 1
	i = 0
	for entity in moving_entities:
		EntityBehavior.move_to(entity, entity.destination)
	#for entity in moving_entities:
		if entity.position.distance_to(entity.destination) < 100:
			entity.linear_velocity *= 0.15
			idle_entities.append(entity)
			array_swapback(moving_entities, i)
		i += 1

func array_swapback(array,index):
	## This removes the element we want, then swaps the element at the very back with the element we remove. 
	## Because we care not about the order of the array.
	array[index] = array[array.size() - 1]
	array.remove_at(array.size() - 1)
