extends "behavior_creature.gd"

var nav_timer = 0
var nav_timeout = 400
var nav_timeout_min = 200
var nav_timeout_max = 1400
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav_timer = nav_timeout - 30
	pass # Replace with function body.


## What does a bison do?

# 1) Pick a random spot to eat
# 2) Stay near its herd.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if nav_timer < nav_timeout and entity.active_threat == null:
		nav_timer += 1
	elif entity.active_threat == null:
		nav_timer = 0
		#print(village_nav_node.locations)
		#entity.destination = entity.get_destination()
		nav_timeout = randi_range(nav_timeout_min,entity.position.distance_to(entity.destination))
	pass

## Find Grass to Eat
