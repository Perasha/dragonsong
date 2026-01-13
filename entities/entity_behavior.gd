extends Node

## ENTITY BEHAVIOR-------

# States
enum {IDLE,SEARCHING_FOOD}

# Pathfind
# Eat

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
var choice = [-500,500]
# Wander
func wander(entity):
	# Randomly choose a point
	choice.shuffle()
	var temp_direction = choice.pick_random()
	temp_direction *= randi_range(1,3)
	entity.destination = Vector2(temp_direction,entity.position.y)

## Herd Behavior

## Find Food

# Pick a random direction
