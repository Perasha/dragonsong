extends RigidBody2D

@export var speed = 5.00
#@export var jump_height = -400.00
@export var max_walk_speed = 200.00
@export var max_run_speed = 400.00
@export var max_fly_speed = 1250.00
var max_fly_speed_base = GlobalData.terminal_velocity / 2.5#1.5
var terminal_velocity = 2000.00

@onready var floor_check = get_node("FloorCheck")
#@onready var sprite = get_node("Body") #Animator
@onready var wingbeat_clock = get_node("wingbeat_clock")
var wingbeat_timer_min = 0.25
@onready var resources = get_node("Resources")
#@onready var interact_field = get_node("InteractArea")
@onready var climb_detector = get_node("ClimbDetector")
#@onready var GlobalData = get_parent()
#@onready var dive_toggler = get_node("DiveToggler")

#var base_gravity_scale = 2.0
#var fly_gravity_scale = 0.3
var distance_moved = 0.0
var previous_position = Vector2(0.0,0.0)
var current_position = Vector2(0.0,0.0)

var just_jumped = false
var jump_strength = 0.0
var stored_jump = 0.0
#var is_running = false
var direction_x
var direction_y
var is_stalling

var is_flying = false
var is_hovering = false
var is_gliding = false
var is_running = false
var is_climbing = false
var is_flap_held = false

var is_grounded = false
# Option to change from glide being a toggle, to being held
#var option_hold_to_glide = false
#var option_hold_to_hover = false

var on_wingbeat_cooldown = false
#@export var wingbeat_afterburner_base = 6.0
var wingbeat_afterburner = 0.0

@export var hover_speed = 20.0

var current_speed = 0.0
@export var turn_radius = 0.1
var fd_dampen = 0.0
# Multiplier for our dampen value; this is proportional to our GRAVITY constant.
@export var dampen_base = 0.3 
var dampen_glide = dampen_base / 6.0#0.05 
#var gravity = 150

@export var grav_scale_default = 2.0

var flight_direction = Vector2(0.0,0.0)
var max_glide_height = 0.0

func _ready() -> void:
	jump_strength = jump_strength_base
	terminal_velocity = GlobalData.terminal_velocity
	#max_fly_speed_base = terminal_velocity
	#max_fly_speed = max_fly_speed_base


func _physics_process(delta: float) -> void:
	just_jumped = false
	is_running = false
	is_climbing = false
	#is_grounded = false
	is_grounded = floor_check.is_colliding()
	previous_position = current_position
	current_position = position
	gravity_scale = grav_scale_default
	
	#if position.y < 0:
		#max_fly_speed = max_fly_speed_base * (-position.y / 3000)
		#if max_fly_speed < max_fly_speed_base:
			#max_fly_speed = max_fly_speed_base
	#else:
		#max_fly_speed = max_fly_speed_base
	## Here, we take the X and Y of our Linear Velocity and combine it into a total speed value.
	## And uh, we needed the Pythoreum Theorum for it.
	current_speed = pow(abs(linear_velocity.x),2) + pow(abs(linear_velocity.y),2)
	current_speed = sqrt(current_speed)
	## Now, we're constantly pushing our Flight Direction (the thing that dictates which way we go when we fly) down.
	## That's because of gravity! Because otherwise, well, we're always adding force forward and it's
	## not enough to cancel out the built-in gravity.
	## Also it lets us do cool diving maneuvers.
	
	## So first, we set our dampening value.
	fd_dampen = dampen_base
	if not is_hovering:
		if not is_flying:
			flight_direction.y = 1
		
	check_climb()
	## Now we get inputs. Our wing flap, then movement axes, then our wing-fold/dive.
	if Input.is_action_pressed("flap"):
		is_flap_held = true
		if jump_strength <= max_jump_strength:
			jump_strength += 0.1
	if Input.is_action_just_released("flap"):
		#is_hovering = false
		just_jumped = true
		is_flap_held = false
		stored_jump = jump_strength
	
	direction_x = Input.get_axis("move_left", "move_right")
	direction_y = Input.get_axis("move_up", "move_down")
	
	## Disabling Stalling to instead modify our direction_y based on our speed
	#print("Old FD_Dampen: ", fd_dampen)
	fd_dampen = (1.0 - (current_speed / terminal_velocity))
	#fd_dampen = fd_dampen ** 10
	fd_dampen *= 0.011
	#print("Stalling Test: ", fd_dampen)
	#print(fd_dampen)
	if is_gliding:
		fd_dampen *= 0.25
	flight_direction.y += fd_dampen	
	
	## If option_hold_to_glide is on, then you need to hold to fold in wings. Otherwise, it's a toggle.
	## Some players might prefer one way or the other so it's a good option to have.
	if is_flying:
		if Input.is_action_just_pressed("Glide"):
			if not GlobalData.option_hold_to_glide:
				if is_gliding == true:
					is_gliding = false
				else:
					is_gliding = true
					is_hovering = false
		if Input.is_action_pressed("Glide"):
			if GlobalData.option_hold_to_glide:
				is_gliding = true
				is_hovering = false
		if Input.is_action_just_released("Glide"):
			if GlobalData.option_hold_to_glide:
				is_gliding = false
	else:
		is_hovering = false
		is_gliding = false
		if Input.is_action_pressed("Glide"):
			is_running = true
	## And here's the same thing for Hovering
	if Input.is_action_just_pressed("Hover"):
		if not GlobalData.option_hold_to_hover:
			if is_hovering == true:
				is_hovering = false
			else:
				is_hovering = true
				is_gliding = false
	if Input.is_action_pressed("Hover"):
		if GlobalData.option_hold_to_hover:
			is_hovering = true
			is_gliding = false
	if Input.is_action_just_released("Hover"):
		if GlobalData.option_hold_to_hover:
			is_hovering = false
	
	if is_hovering and not is_grounded:
		is_flying = true
	
	## If our wings are out, it's a bit harder to make sharp turns. But if they're in, we can make sharp turns!
	if is_hovering:
		turn_radius = 0.4
	elif is_gliding:
		turn_radius = 0.03
	else:
		turn_radius = 0.05
		
	## This is where we use our turning radius. We incrementally will be adding this value to
	## our Flight Direction every tick, which will go against the gravity that constantly pushes it down.
	flight_direction += Vector2(direction_x,direction_y) * turn_radius
	## Oh and then we make sure that we don't actually go above 1 for either value because that would lead to ~problems~!
	flight_direction = flight_direction.normalized()
	
	
	## This is our jump! If we flap once, it's just a jump. If we flap twice, and we're not on the ground, we start flying!	
	if just_jumped:
		if not is_grounded and not is_flying:
			if flight_direction.y > 0:
				flight_direction.y *= -1
			wingbeat()
			is_flying = true
			
			if GlobalData.option_hover_leave:
				is_hovering = true
			else:
				## If Glide on Fly is true:
				is_gliding = true
	
		## If we're hovering, manually set flight_direction so that we have an easy transition
		elif is_hovering:
			is_hovering = false
			## If Glide on Fly is true:
			is_gliding = true
			wingbeat()
	
	if is_grounded:
		is_flying = false
	
	if not is_flying and not is_grounded:
		if distance_moved > 18 or just_jumped:
			is_flying = true
			## If Glide on Fly is true:
			is_gliding = true
	
	## If we're on the ground, add some directly upward velocity if we flap our wings!
	if just_jumped and is_grounded:
		linear_velocity.x += (direction_x * (wingbeat_strength * stored_jump)) * 2
		linear_velocity.y -= (wingbeat_strength * stored_jump) * 4
	
	if not is_flying or hover_speed == 0:
		is_hovering = false
	
	## MOVEMENT
	if is_flying and not is_hovering:
		fly()
	elif is_hovering:
		var max_hover_speed = max_fly_speed / 1.8
		hover(max_hover_speed,hover_speed)
	elif is_climbing:
		climb()
	else:
		walk()
	if is_flying or is_hovering:
		## This is just to make sure our speed never exceeds what we determine as Terminal Velocity. Otherwise... bad things
		linear_velocity = linear_velocity.clamp(Vector2(-terminal_velocity,-terminal_velocity),Vector2(terminal_velocity,terminal_velocity))
	## Oh and finally, we calculate our distance moved!
	distance_moved = previous_position.distance_to(current_position)
	if just_jumped:
		jump_strength = jump_strength_base
		
		#linear_velocity -= linear_velocity.direction_to(Vector2(0,0)) * 50
	
	if resources.health == 0:
		is_gliding = false
## END PHYSICS_PROCESS------------------------------------------------

@onready var reset_pos = global_position
var reset = false

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
#	if reset:
#		state.transform.origin = reset_pos
#		## Call reset_physics_interpolation() at the end of the frame once the physics engine has been updated
#		reset_physics_interpolation.call_deferred()
#		reset = false
@export_category("Wingbeat Parameters")
@export var wingbeat_strength = 200.00
@export var afterburner_amount = 6.0
@export var stored_jump_multiplier = 1.0
@export var jump_strength_base = 2.0
@export var max_jump_strength = 4.0

func wingbeat():
	## Lifting us up ever so slightly
	#print(flight_direction.y)
	if not direction_x and flight_direction.y < 0.4:
		#print("Flying upwards")
		flight_direction.y -= (stored_jump-2) / 9
	
	stored_jump *= stored_jump_multiplier
	var wingbeat_force = 0.0
	
	#print(terminal_velocity)
	if current_speed < terminal_velocity:
		## Adding an "afterburner" to continually apply force after we do a wingbeat.
		
		
		wingbeat_afterburner = (stored_jump * afterburner_amount)
		
		#var speed_reduction = current_speed / 10
		#print("Current speed: ", speed_reduction)
		#print("Afterburner: ", wingbeat_afterburner)
		#print("Wingbeat Force: ", wingbeat_strength * stored_jump)
		#print("Speed-reduced wingbeat force: ", (wingbeat_strength * stored_jump) - speed_reduction)
		
		wingbeat_force = (wingbeat_strength * stored_jump)# - speed_reduction
		#print("Modified Wingbeat Force: ", wingbeat_force)
		if wingbeat_force < 0:
			wingbeat_force = 0
		## I uh... don't know what values to shift.
		#print("Final Wingbeat Force: ", wingbeat_force)
		if is_gliding:
			current_speed += wingbeat_force# / int((distance_moved / 20) + 1)
		else:
			wingbeat_force *= 1.25
			current_speed += wingbeat_force# / int((distance_moved / 10) + 1)
		#current_speed -= speed_reduction
	if current_speed > terminal_velocity:
		current_speed = terminal_velocity
	
	on_wingbeat_cooldown = true
	var new_wait_time = 0.11 * (stored_jump * stored_jump)
	#print(new_wait_time)
	wingbeat_clock.wait_time = new_wait_time
	wingbeat_clock.start()
	
## SUPER IMPORTANT!
		## Here, we're actually dividing our current speed among our new directions.
		## Remember when we evenly merged our Linear Velocity earlier?
		## That's because we need to redivide it! Except among two NEW slightly different directions.
		## If we were pointing up, and now we're pointing down, the same speed is now being transferred to that direction.
		## And that's how we keep our momentum!
		## And also, if we stall, we actually immediately drop our direction downward.
func apply_momentum():
	linear_velocity.x = (current_speed * flight_direction.x)
	linear_velocity.y = (current_speed * flight_direction.y)
	if flight_direction.y < 0:
		gravity_scale = grav_scale_default / 1.5
	else:
		gravity_scale = grav_scale_default * 1.2
	pass


## Flying
func fly():
	if just_jumped and current_speed <= terminal_velocity and not on_wingbeat_cooldown:
		wingbeat()
		#print("Continue")
	## Adding our afterburner force. This'll slowly go down long after we do the wingbeat, but it's to push us further for a bit longer.
	if wingbeat_afterburner > 1:
		wingbeat_afterburner /= 1.04
		current_speed += wingbeat_afterburner * 0.6
		
	if current_speed >= 20:
		apply_momentum()
	else:
		flight_direction.y = 1.0

## Hovering
func hover(max_speed,acceleration):
	#print("Hovering: ", max_fly_speed)
	gravity_scale = 0.0
	#max_hover_speed = max_fly_speed / 1.25
	#flight_direction = Vector2(direction_x,direction_y)
	if current_speed <= max_speed:
		#print("Hovering: ", max_fly_speed)
		var hover_direction = Vector2(direction_x,direction_y).normalized() * acceleration
		linear_velocity.x += hover_direction.x
		if linear_velocity.y > -(max_speed * 0.72):
			linear_velocity.y += hover_direction.y
			
	# Stopping much more abruptly if we aren't trying to move,
	# OR if one of the directions is directly opposite of another.
	if direction_x == 0 and direction_y == 0:
		linear_velocity /= 1 + (acceleration / 750.0)
	else:
		if (-direction_x > 0 and linear_velocity.x > 0) or (-direction_x < 0 and linear_velocity.x < 0):
			linear_velocity.x /= 1 + (acceleration / 750.0)
		if (-direction_y > 0 and linear_velocity.y > 0) or (-direction_y < 0 and linear_velocity.y < 0):
			linear_velocity.y /= 1 + (acceleration / 750.0)
	
	# Steering Radius
	linear_velocity += linear_velocity.direction_to(Vector2(0,0)) * 15

## Climbing
func check_climb():
	#print("checking climb")
	if climb_detector.is_colliding() and abs(direction_x) > 0.2:
		is_climbing = true
		is_flying = false
		is_hovering = false
		#else:
		#	print("Grounded, no climbing")
	
	
	#if abs(linear_velocity.x) > 50 and abs(flight_direction.x) == 1.0 and not is_grounded:
	#	is_climbing = true
		#gravity_scale = 0.0
	pass

func climb():
	#print("Climbing!")
	hover(max_run_speed,speed)

## Walking
func walk():
## Start moving in a direction if we move left and right. Not very fast, mind you.
	var speed_limit = max_walk_speed
	if is_running: speed_limit = max_run_speed
	if direction_x:
		#physics_material_override.friction = 0.0
		flight_direction.x = direction_x
		if abs(linear_velocity.x) < speed_limit:
			linear_velocity.x += direction_x * speed
	## This actually more quickly slows our movement, rather than increasing our friction.
	## Using them legs to slow down!
	## But only if we're touching the floor.
	if is_grounded:
		linear_velocity.x *= 0.95



func _on_wingbeat_clock_timeout() -> void:
	on_wingbeat_cooldown = false

func _on_injure_button_up() -> void:
	resources.health_update(-10)

func _on_heal_button_up() -> void:
	resources.health_update(10)

# Fall damage
func _on_body_entered(body: Node) -> void:
	#print(distance_moved)
	if distance_moved > 20:
		#resources.health_update(snappedf(-distance_moved / 200,0.01))
		resources.health_update(snappedf(-distance_moved / 2,1.0))
	pass # Replace with function body.
