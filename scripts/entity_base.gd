extends "object_base.gd"

## STATS
@export var health = 0.10
##-------------------------


@export var is_grounded = false
var entity = true
var dead = false

@onready var behavior_node = get_node("Behavior")
@onready var nav_node = get_parent().get_parent().get_node("NavNodes")
@onready var floor_check = get_node("FloorCheck")
@onready var sprite = get_node("Sprite")
@onready var global_data = get_node("/root/Main")
#global_data.terminal_velocity
var nav_timer = 0
var nav_timeout = 400
var nav_timeout_min = 200
var nav_timeout_max = 1400
var max_speed = 100
var max_run_speed = max_speed * 2

var is_running = false
#var is_grabbed = false

var destination = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = position
	nav_timer = nav_timeout - 30
	pass # Replace with function body.

var previous_position 
var current_position = position
var distance_moved
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_running = false
	previous_position = current_position
	current_position = position
	#print("Linear Velocity", linear_velocity)
	if not is_grabbed and not dead:
		#print(floor_check.has_overlapping_bodies())
		if floor_check.has_overlapping_bodies():
			is_grounded = true
		else:
			is_grounded = false
			#linear_velocity.y += 2
		
		if active_threat != null:
			is_running = true
			# If there's a threat, run in the opposite direction
			move_away_from(active_threat)
		## Try to steer away from other people
		elif floor_check.has_overlapping_areas():
			var choice = [-100,100,0]
			var temp_direction = choice.pick_random()
			if temp_direction == 0:
				pass
			else:
				destination = position + Vector2(temp_direction,0)
	
	if is_grounded and not dead:
		if position.distance_to(destination) > 30:
			#print(position.distance_to(destination))
			move_to(destination)
		if nav_timer < nav_timeout and active_threat == null:
			nav_timer += 1
		else:
			nav_timer = 0
			#print(nav_node.locations)
			destination = get_destination()
			nav_timeout = randi_range(nav_timeout_min,position.distance_to(destination))
	
	distance_moved = previous_position.distance_to(current_position)
	if abs(linear_velocity.x) > global_data.terminal_velocity:
		if linear_velocity.x < 0: linear_velocity.x = -global_data.terminal_velocity
		else: linear_velocity.x = global_data.terminal_velocity
	if abs(linear_velocity.y) > global_data.terminal_velocity:
		if linear_velocity.y < 0: linear_velocity.y = -global_data.terminal_velocity
		else: linear_velocity.y = global_data.terminal_velocity
				#print(destination)

func move_to(destination):
	var direction = position.direction_to(destination)
	var speed_limit = max_speed
	if is_running:
		speed_limit = max_run_speed
	
	if abs(linear_velocity.x) < speed_limit:
		linear_velocity.x += direction.x * 8
	if abs(linear_velocity.x) > speed_limit:
		if linear_velocity.x < 0: linear_velocity.x = -speed_limit
		else: linear_velocity.x = speed_limit
	if abs(linear_velocity.y) > speed_limit:
		if linear_velocity.y > 0: linear_velocity.y = speed_limit
		else: linear_velocity.y = -speed_limit
	if destination.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func get_destination():
	return nav_node.locations.pick_random()

func move_away_from(target):
	destination = position + -(Vector2(position.direction_to(target.position).x,0) * 1000)

var active_threat : RigidBody2D

func damage(value):
	health -= value
	if health < 0:
		health = 0
		dead = true
		sprite.rotation_degrees = 90
		sprite.position.y = 20
		#linear_velocity = Vector2(0,0)
		physics_material_override.friction = 0.5

## FALL DAMAGE
var impact_threshold = 10.0
var impact = 0.0
func _on_body_entered(body: Node) -> void:
	#print("IMPACT, distance moved:", distance_moved)
	
	if distance_moved > impact_threshold:
		impact = distance_moved / 200
		damage(snappedf(impact,0.01))
	pass # Replace with function body.
