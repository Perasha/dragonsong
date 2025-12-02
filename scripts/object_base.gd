extends RigidBody2D

var is_grabbed = false
var can_be_grabbed = true
var grabbing_entity : RigidBody2D
var just_released = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(is_grabbed, grabbing_entity)
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
	
