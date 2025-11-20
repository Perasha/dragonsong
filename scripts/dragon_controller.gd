extends RigidBody2D

@export var wingbeat_strength = 200.00
@export var speed = 5.00
#@export var jump_height = -400.00
@export var max_walk_speed = 200.00
#@export var max_run_speed = 400.00
@export var max_fly_speed = 1250.00
@export var terminal_velocity = 2000.00

@onready var floor_check = get_node("FloorCheck")
@onready var sprite = get_node("Body")
@onready var wingbeat_clock = get_node("wingbeat_clock")
@onready var resources = get_node("Resources")

#var base_gravity_scale = 2.0
#var fly_gravity_scale = 0.3
var distance_moved = 0.0
var previous_position = Vector2(0.0,0.0)
var current_position = Vector2(0.0,0.0)

var just_jumped = false
var jump_counter = 0
@export var jump_strength_base = 2.0
var jump_strength = 2.0
var stored_jump = 0.0
@export var max_jump_strength = 4.0
#var is_running = false
var direction_x
var direction_y
var is_stalling

var is_flying = false
var is_hovering = false
var toggle_glide = false
# Option to change from glide being a toggle, to being held
var option_hold_to_glide = false
var option_hold_to_hover = false

var on_wingbeat_cooldown = false
#@export var wingbeat_afterburner_base = 6.0
var wingbeat_afterburner = 0.0

@export var hover_speed = 15

var current_speed = 0.0
var turn_radius = 0.1
var fd_dampen = .85
# Multiplier for our dampen value; this is proportional to our GRAVITY constant.
var dampen_base = .002125
var dampen_glide = .000125
# Default is 400
var gravity = 150

var grav_scale_default = 2.0

var flight_direction = Vector2(0.0,0.0)

func _ready() -> void:
	jump_strength = jump_strength_base


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	just_jumped = false
	previous_position = current_position
	current_position = position
	gravity_scale = grav_scale_default
	
	# Here, we take the X and Y of our Linear Velocity and combine it into a total speed value.
	# And uh, we needed the Pythoreum Theorum for it.
	current_speed = pow(abs(linear_velocity.x),2) + pow(abs(linear_velocity.y),2)
	current_speed = sqrt(current_speed)
	# Now, we're constantly pushing our Flight Direction (the thing that dictates which way we go when we fly) down.
	# That's because of gravity! Because otherwise, well, we're always adding force forward and it's
	# not enough to cancel out the built-in gravity.
	# Also it lets us do cool diving maneuvers.
	
	# So first, we set our dampening value.
	fd_dampen = dampen_base * gravity
	#print(gravity)
	# First, if our glide is toggled, we lower this dampening value so we get a nice, slow descent.
	# if the distance we moved is low enough, meaning we've slowed down, we'll disable it and start diving.
	# If the distance moved is low and we're flying, that means... we've stalled!
	# Also if we're hovering, skip this ENTIRE thing.
	if not is_hovering:
		if distance_moved < 4 and is_flying:
			is_stalling = true
			fd_dampen = dampen_base
		elif distance_moved > 10 and is_flying:
			is_stalling = false
		if is_flying == false:
			is_stalling = false
		if toggle_glide and not is_stalling:
			fd_dampen = dampen_glide * gravity
		
		if toggle_glide:
			if flight_direction.y < 0.04:
				flight_direction.y += fd_dampen / (distance_moved + fd_dampen)
			#elif flight_direction.y > 0.04:
			#	flight_direction.y -= fd_dampen / (distance_moved + fd_dampen)
		# Now here's the actual dampening.
		# We first make sure that we are flying *and* that our flight direction isn't directly up (meaning we have enough force to fly up)
		elif flight_direction.y < 0.95:
			# We take our dampening value, and divide it by the distance moved. 
			# We also then add our dampening value to that number so that we don't accidentally divide by zero.
			flight_direction.y += fd_dampen / (distance_moved + fd_dampen)
		elif not is_flying:
			flight_direction.y = 1
	# If we ARE hovering
	else:
		is_stalling = false
	
	# Now we get inputs. Our wing flap, then movement axes, then our wing-fold/dive.
	#if Input.is_action_just_pressed("flap"):
	#	just_jumped = true
	#	jump_counter += 1
	if Input.is_action_pressed("flap"):
		#toggle_glide = true
		if jump_strength <= max_jump_strength:
			jump_strength += 0.1
	if Input.is_action_just_released("flap"):
		#toggle_glide = false
		is_hovering = false
		just_jumped = true
		if jump_counter < 2:
			jump_counter += 1
		stored_jump = jump_strength
	
	direction_x = Input.get_axis("ui_left", "ui_right")
	direction_y = Input.get_axis("ui_up", "ui_down")
		
	#If we're stalling, we can't climb. So we specifically anchor our Y direction down.
	if is_stalling:
		#direction_x *= 0.25
		direction_y = 1
	
	# Can we make our Direction proportional to our speed? 
	# For example, if we're going too slow, 
	
	
	# If option_hold_to_glide is on, then you need to hold to fold in wings. Otherwise, it's a toggle.
	# Some players might prefer one way or the other so it's a good option to have. 
	if Input.is_action_just_pressed("Slow"):
		if not option_hold_to_glide:
			if toggle_glide == true:
				toggle_glide = false
			else:
				toggle_glide = true
	if Input.is_action_pressed("Slow"):
		if option_hold_to_glide:
			toggle_glide = true		
	if Input.is_action_just_released("Slow"):
		if option_hold_to_glide:
			toggle_glide = false
	
	# And here's the same thing for Hovering
	if Input.is_action_just_pressed("Hover"):
		if not option_hold_to_hover:
			if is_hovering == true:
				is_hovering = false
			else:
				is_hovering = true
	if Input.is_action_pressed("Hover"):
		if option_hold_to_hover:
			is_hovering = true		
	if Input.is_action_just_released("Hover"):
		if option_hold_to_hover:
			is_hovering = false
	
	# However, if our Stamina is 0, we can't glide.
	#if resources.stamina < 1:
	#	toggle_glide = false
	#	direction_y = 0
	
	# If our wings are out, it's a bit harder to make sharp turns. But if they're in, we can make sharp turns!
	if is_hovering:
		turn_radius = 0.2
	elif toggle_glide:
		turn_radius = 0.04
		gravity_scale = grav_scale_default
	else:
		turn_radius = 0.07
		gravity_scale = 2.5
	#print(turn_radius)
		
	# This is where we use our turning radius. We incrementally will be adding this value to
	# our Flight Direction every tick, which will go against the gravity that constantly pushes it down.
	flight_direction += Vector2(direction_x,direction_y) * turn_radius
	# Oh and then we make sure that we don't actually go above 1 for either value because that would lead to ~problems~!
	flight_direction = flight_direction.normalized()
	
	
	# This is our jump! If we flap once, it's just a jump. If we flap twice, and we're not on the ground, we start flying!
	if jump_counter == 1 and not floor_check.has_overlapping_bodies():
		# OPTIONT TO DISABLE HOVER
		if flight_direction.y > 0:
			flight_direction.y *= -1
		wingbeat()
		is_flying = true
		#is_hovering = true
		jump_counter += 1
	elif floor_check.has_overlapping_bodies():
		is_flying = false
	
	if floor_check.has_overlapping_bodies():
		is_flying = false
		jump_counter = 0
	
	if distance_moved > 12 and not floor_check.has_overlapping_bodies():
		is_flying = true
		if jump_counter == 0:
			jump_counter += 2
	
	if is_hovering and not floor_check.has_overlapping_bodies():
		is_flying = true
	
	if not is_flying or hover_speed == 0:
		is_hovering = false
	# Flying movement.
	
	if is_flying and not is_hovering:
		if just_jumped and current_speed <= terminal_velocity and not on_wingbeat_cooldown:
			wingbeat()
			#print("Continue")
		# Adding our afterburner force. This'll slowly go down long after we do the wingbeat, but it's to push us further for a bit longer.
		if wingbeat_afterburner > 0:
			wingbeat_afterburner -= 0.8
			current_speed += wingbeat_afterburner
			
		if current_speed >= 20:
			apply_momentum()
		else:
			flight_direction.y = 1.0
	# Hovering Movement
	elif is_hovering:
		#print("Hovering: ", max_fly_speed)
		gravity_scale = 0.0
		#flight_direction = Vector2(direction_x,direction_y)
		if current_speed <= max_fly_speed:
			#print("Hovering: ", max_fly_speed)
			var hover_direction = Vector2(direction_x,direction_y).normalized() * hover_speed
			linear_velocity.x += hover_direction.x
			if linear_velocity.y > -(max_fly_speed * 0.72):
				linear_velocity.y += hover_direction.y
			#if linear_velocity.y < 0:
			#	linear_velocity.y /= 1.005
			#linear_velocity = linear_velocity.normalized()
		#print(linear_velocity.direction_to(Vector2(0,0)))
		# Stopping much more abruptly if we aren't trying to move
		if direction_x == 0 and direction_y == 0:
			linear_velocity /= 1.02
		linear_velocity += linear_velocity.direction_to(Vector2(0,0)) * 10
	# Grounded movement.
	else:
		# And start moving in a direction if we move left and right. Not very fast, mind you.
		if direction_x:
			flight_direction.x = direction_x
			if abs(linear_velocity.x) < max_walk_speed:
				linear_velocity.x += direction_x * speed
			#linear_velocity = linear_velocity.clamp(Vector2(-max_walk_speed,-terminal_velocity),Vector2(max_walk_speed,terminal_velocity))
		
		# Add some directly upward velocity if we flap our wings!
		if just_jumped:
			stored_jump *= 0.75
 			#stored_jump = resources.consume_stamina(stored_jump)
			linear_velocity.y -= wingbeat_strength * stored_jump
			stored_jump *= 0.75
			linear_velocity.x += direction_x * (wingbeat_strength * stored_jump)
			#linear_velocity.y -= wingbeat_strength * jump_strength * 1.25		
		# This actually more quickly slows our movement, rather than increasing our friction.
		# Using them legs to slow down!
		# But only if we're touching the floor.
		if floor_check.has_overlapping_bodies():
			linear_velocity.x *= 0.95
		# And again, clamping our speed just to make sure nothing breaks.
		# X axis can be our maximum walking speed, but up and down are determined by air resistance!
		#linear_velocity = linear_velocity.clamp(Vector2(-terminal_velocity,-terminal_velocity),Vector2(terminal_velocity,terminal_velocity))
	if is_flying or is_hovering:
		# This is just to make sure our speed never exceeds what we determine as Terminal Velocity. Otherwise... bad things
		linear_velocity = linear_velocity.clamp(Vector2(-terminal_velocity,-terminal_velocity),Vector2(terminal_velocity,terminal_velocity))
	# Oh and finally, we calculate our distance moved!
	distance_moved = previous_position.distance_to(current_position)
	if just_jumped:
		jump_strength = jump_strength_base
		
		#linear_velocity -= linear_velocity.direction_to(Vector2(0,0)) * 50
	
	if resources.health == 0:
		toggle_glide = false
# END PHYSICS_PROCESS------------------------------------------------

@onready var reset_pos = global_position
var reset = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if reset:
		state.transform.origin = reset_pos
		# Call reset_physics_interpolation() at the end of the frame once the physics engine has been updated
		reset_physics_interpolation.call_deferred()
		reset = false

func wingbeat():
	wingbeat_clock.start()
	#flight_direction.y -= 0.1
	#if toggle_glide:
	#	flight_direction.y = lerp(flight_direction.y, -1.0, 0.15)
	#else:
	#	flight_direction.y = -0.45
	if current_speed <= max_fly_speed:
		# Adding an "afterburner" to continually apply force after we do a wingbeat.
		wingbeat_afterburner = (stored_jump * 3)
		#print("Wingbeat!")
		#print(current_speed)
		if toggle_glide:
			current_speed += (wingbeat_strength * stored_jump) / int((distance_moved / 20) + 1)
		else:
			current_speed += (wingbeat_strength * stored_jump * 1.25) / int((distance_moved / 10) + 1)
		#print(current_speed)
		apply_momentum()
	on_wingbeat_cooldown = true
	
	#resources.consume_stamina(stored_jump)
	
## SUPER IMPORTANT!
		# Here, we're actually dividing our current speed among our new directions.
		# Remember when we evenly merged our Linear Velocity earlier?
		# That's because we need to redivide it! Except among two NEW slightly different directions.
		# If we were pointing up, and now we're pointing down, the same speed is now being transferred to that direction.
		# And that's how we keep our momentum!
		# And also, if we stall, we actually immediately drop our direction downward.
func apply_momentum():
	linear_velocity.x = (current_speed * flight_direction.x)
	linear_velocity.y = (current_speed * flight_direction.y)
	if flight_direction.y < 0:
		gravity_scale = grav_scale_default / 1.5
	else:
		gravity_scale = grav_scale_default * 2.0
	

func _on_wingbeat_clock_timeout() -> void:
	on_wingbeat_cooldown = false

@onready var initial_speed = {
	"max_jump_strength" : max_jump_strength,
	"max_fly_speed" : max_fly_speed,
	"hover_speed" : hover_speed
}
var injury_multiplier = 1.0
# Hypothetically this should slow us down the more injured we are.
func _on_injure_button_up() -> void:
	health_update(-1)

func _on_heal_button_up() -> void:
	health_update(1)


func health_update(value):
	resources.health += value
	hover_speed = initial_speed["hover_speed"]
	if resources.health > resources.max_health:
		resources.health = resources.max_health
	
	if resources.health > 0:
		injury_multiplier = resources.health / resources.max_health
		#wingbeat_strength *= resources.health / resources.max_health
		#speed *= resources.health / resources.max_health
		#jump_strength_base *= resources.health / resources.max_health
		#max_jump_strength *= resources.health / resources.max_health
		#hover_speed = injury_multiplier * initial_speed["hover_speed"]
		max_fly_speed = injury_multiplier * initial_speed["max_fly_speed"]
		max_jump_strength = (injury_multiplier * (initial_speed["max_jump_strength"] - jump_strength_base)) + jump_strength_base
		print("INJURY: ", max_fly_speed)
	else:
		max_jump_strength = 3
		hover_speed = 0
		resources.health = 0
