extends Node

@onready var entity_manager = get_node("/root/EntityManager")

## ENTITY BEHAVIOR-------

## States
#enum {GRABBED,GRABBING,DEAD,MOVE_RUN,MOVE,STAND}
enum {IDLE,MOVE,GRABBED,DEAD}

func health_update(entity, value):
	entity.health += value

## Pathfind
## Eat

## Grab
#func try_grab(entity,grabbing_entity):
#	pass

## Idle
#func idle(entity):
	#entity.linear_velocity *= 0.75
	#entity.nav_timer += 1
	#entity.thought = IDLE

## Move
func move_to(entity, destination):
	entity.destination = destination
	var direction = entity.position.direction_to(destination)
	var speed_limit = entity.speed
	
	if entity.is_running:
		speed_limit = entity.speed * 2
	
	if abs(entity.linear_velocity.x) < speed_limit:
		entity.linear_velocity.x += direction.x * 8
	if abs(entity.linear_velocity.x) > speed_limit:
		if entity.linear_velocity.x < 0: entity.linear_velocity.x = -speed_limit
		else: entity.linear_velocity.x = speed_limit
	if abs(entity.linear_velocity.y) > speed_limit:
		if entity.linear_velocity.y > 0: entity.linear_velocity.y = speed_limit
		else: entity.linear_velocity.y = -speed_limit
	if destination.x > entity.position.x:
		entity.sprite.flip_h = true
	else:
		entity.sprite.flip_h = false
	entity.destination.y = entity.position.y


## PATHFINDING
var choice = [1,-1]
var temp_direction = 0
# Wander
func wander(entity):
	# Randomly choose a point
	#choice.shuffle()
	randomize()
	temp_direction = choice.pick_random()
	temp_direction *= randi_range(300,2500)
	entity.destination = Vector2(temp_direction,entity.position.y)
	entity.thought = MOVE

## Herd Behavior

## Find Food

## Pick a random direction
