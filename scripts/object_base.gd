extends RigidBody2D

@onready var global_data = get_node("/root/Main")

var is_grabbed = false
var can_be_grabbed = true
var grabbing_entity : RigidBody2D
var just_released = false

var previous_position = position
var current_position = position
var distance_moved
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	previous_position = current_position
	current_position = position
	#print(is_grabbed, grabbing_entity)
	distance_moved = previous_position.distance_to(current_position)
	if abs(linear_velocity.x) > global_data.terminal_velocity:
		if linear_velocity.x < 0: linear_velocity.x = -global_data.terminal_velocity
		else: linear_velocity.x = global_data.terminal_velocity
	if abs(linear_velocity.y) > global_data.terminal_velocity:
		if linear_velocity.y < 0: linear_velocity.y = -global_data.terminal_velocity
		else: linear_velocity.y = global_data.terminal_velocity
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#print(is_grabbed, grabbing_entity)
	
	## Error checking
	#if grabbing_entity != null:
	#	print(position, ", entity position: ", grabbing_entity.position)
	#if is_grabbed and grabbing_entity == null:
	#	just_released = true
	#	is_grabbed = false
	#	reset_physics_interpolation.call_deferred()
	
	
	if just_released:
		#print("Releasing!")
		custom_integrator = false
		is_grabbed = false
		if grabbing_entity != null:
			linear_velocity = grabbing_entity.linear_velocity
		else:
			print("Error caught!")
		grabbing_entity = null
		reset_physics_interpolation.call_deferred()
		just_released = false
		#custom_integrator = false
	elif is_grabbed:
		reset_physics_interpolation.call_deferred()
		#custom_integrator = true
		#print("Is grabbed!")
		state.transform.origin = grabbing_entity.position
		custom_integrator = true
		# Call reset_physics_interpolation() at the end of the frame once the physics engine has been updated
		#reset_physics_interpolation()
	
## DAMAGE AREA FOR OBJECTS
var impact_threshold = 10.0
var impact = 0.0
func _on_area_2d_body_entered(body: Node2D) -> void:
	if distance_moved > impact_threshold:
		impact = distance_moved / 200
		if body.is_in_group("entity"):
			body.damage(snappedf(impact,0.01))
		elif body.is_in_group("player") and (distance_moved - body.distance_moved) > impact_threshold:
			impact = (distance_moved - body.distance_moved) / 200
			body.health_update(snappedf(-impact,-0.01))
	pass # Replace with function body.
