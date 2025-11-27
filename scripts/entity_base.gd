extends RigidBody2D

var is_grounded = false
var entity = true
var can_be_grabbed = true
var grabbing_entity : RigidBody2D

@onready var nav_node = get_parent().get_parent().get_node("NavNodes")
@onready var floor_check = get_node("FloorCheck")
var nav_timer = 0
var nav_timeout = 400
var nav_timeout_min = 200
var nav_timeout_max = 600
var max_speed = 100
var max_run_speed = max_speed * 2

var is_running = false
var is_grabbed = false

var destination = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = position
	nav_timer = nav_timeout - 30
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_running = false
	if not is_grabbed:
		if floor_check.has_overlapping_bodies():
			is_grounded = true
		else:
			is_grounded = false
			#linear_velocity.y += 2
		
		if active_threat != null:
			is_running = true
			#print("active threat position: ", active_threat.position)
			#print("Position: ", position)
			# If there's a threat, run in the opposite direction
			destination = position + -(Vector2(position.direction_to(active_threat.position).x,0) * 1000)
			#print("destination")
		if position.distance_to(destination) > 30:
			#print(position.distance_to(destination))
			move_to(destination)
		else:
			linear_velocity = Vector2(0,0)
		if nav_timer < nav_timeout and active_threat == null:
			nav_timer += 1
		else:
			nav_timer = 0
			#print(nav_node.locations)
			destination = get_destination()
			nav_timeout = randi_range(nav_timeout_min,position.distance_to(destination))
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
	#print("Linear Velocity", linear_velocity)

func get_destination():
	return nav_node.locations.pick_random()

var active_threat : RigidBody2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Presence":
		#print("DRAGON!!")
		active_threat = area.get_parent()
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.name == "Presence":
		#print("Safe")
		active_threat = null
	pass # Replace with function body.

# When we need to teleport the entity.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_grabbed:
		#print("Is grabbed!")
		state.transform.origin = grabbing_entity.position
			# Call reset_physics_interpolation() at the end of the frame once the physics engine has been updated
		reset_physics_interpolation.call_deferred()

func release_grab():
	is_grabbed = false
	grabbing_entity = null
	pass
