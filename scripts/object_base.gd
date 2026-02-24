extends RigidBody2D

#var is_grabbed = false
#var can_be_grabbed = true
var grabbing_entity : RigidBody2D
var just_released = false

@onready var sprite = get_node("Sprite")

#var previous_position = position
#var current_position = position
#var distance_moved

# If the item is a Quest item, create a signal that'll connect to the Quest Manager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#previous_position = current_position
	#current_position = position
	##print(is_grabbed, grabbing_entity)
	#distance_moved = previous_position.distance_to(current_position)
	
	## Keeps object from going passed terminal velocity
	if abs(linear_velocity.x) > GlobalData.terminal_velocity:
		if linear_velocity.x < 0: linear_velocity.x = -GlobalData.terminal_velocity
		else: linear_velocity.x = GlobalData.terminal_velocity
	if abs(linear_velocity.y) > GlobalData.terminal_velocity:
		if linear_velocity.y < 0: linear_velocity.y = -GlobalData.terminal_velocity
		else: linear_velocity.y = GlobalData.terminal_velocity
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	if grabbing_entity:
		reset_physics_interpolation.call_deferred()
		state.transform.origin = grabbing_entity.position
		custom_integrator = true
		# Call reset_physics_interpolation() at the end of the frame once the physics engine has been updated
		#reset_physics_interpolation()
	elif just_released:
		#print("Releasing!")
		custom_integrator = false
		#is_grabbed = false
		if grabbing_entity != null:
			linear_velocity = grabbing_entity.linear_velocity
		else:
			print("Error caught!")
		grabbing_entity = null
		reset_physics_interpolation.call_deferred()
		just_released = false
