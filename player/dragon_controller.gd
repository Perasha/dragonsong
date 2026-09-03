extends RigidBody2D

@export var speed = 5.00
#@export var jump_height = -400.00
@export var max_walk_speed = 200.00
@export var max_run_speed = 400.00
@export var max_fly_speed_base = 1600#GlobalData.terminal_velocity / 2.5#1.5
var max_fly_speed = max_fly_speed_base
#var GlobalData.terminal_velocity = 2000.00

@onready var floor_check = get_node("FloorCheck")
#@onready var sprite = get_node("Body") #Animator
@onready var wingbeat_clock = get_node("wingbeat_clock")
var wingbeat_timer_min = 0.25
@onready var resources = get_node("Resources")
@onready var interact_field = get_node("InteractArea")
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
var direction_x
var direction_y

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
@export var turn_radius_base = 0.1
@export var glide_turn_radius = 0.5
var turn_radius = 0.1

## Flight Direction Dampening - this value gets added to our Y every frame.
## The lower this number, the less gravity pulls us down.
@export var fd_dampen = 0.0
var minimum_damp = 0.002
@export var maximum_damp = 0.1
## 
var dampen_base = 0.01 
@export var dampen_glide = 0.003# = dampen_base / 6.0#0.05 
#var gravity = 150

@export var grav_scale_default = 2.0
@export var takeoff_speed = 1.0

var flight_direction = Vector2(0.0,0.0)
var max_glide_height = 0.0
var flap_hold_timer = 0
#var slow_force = Vector2(0,0)
# Base = 150

#@export var slow_speed = 800 ## If we go slower than this, we start stalling/going down faster.
#@export var slow_speed_gliding = 400
var speed_range
var dampen_range

var recent_jump_strength = 0.0

func _ready() -> void:
	jump_strength = jump_strength_base
	#terminal_velocity = GlobalData.terminal_velocity
	#max_fly_speed_base = GlobalData.terminal_velocity
	#max_fly_speed = max_fly_speed_base


func _physics_process(delta: float) -> void:
	#print("DRAGON PHYSICS PROCESS START ---------------------------")
	#print("Flight Direction: ", flight_direction)
	just_jumped = false
	is_running = false
	is_climbing = false
	#is_grounded = false
	is_grounded = floor_check.is_colliding()
	previous_position = current_position
	current_position = position
	gravity_scale = grav_scale_default
	
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
			flight_direction.y = 0
		
	check_climb()
	## Now we get inputs. Our wing flap, then movement axes, then our wing-fold/dive.
	if Input.is_action_pressed("flap"):
		is_flap_held = true
		if jump_strength <= max_jump_strength:
			jump_strength += 0.1
	if Input.is_action_just_released("flap"):
		if GlobalData.hover_unlocked == false:
			is_hovering = false
		just_jumped = true
		#is_flap_held = false
		stored_jump = jump_strength
		#flap_hold_timer = 0
	direction_x = Input.get_axis("move_left", "move_right")
	direction_y = Input.get_axis("move_up", "move_down")
	
	if not GlobalData.hover_unlocked and is_hovering:
		direction_x = 0
		direction_y = 0
	#print(direction_x, " ", direction_y)
	if direction_x != 0.0 and flight_direction.y > 0: #current_speed < 1000 and 
		flight_direction.y -= 0.008
	
	## If option_hold_to_glide is on, then you need to hold to fold in wings. Otherwise, it's a toggle.
	## Some players might prefer one way or the other so it's a good option to have.
	if is_flying:
		#if is_gliding:
		#	speed_range = slow_speed_gliding
		#else:
		#	speed_range = slow_speed
			#if is_flying:
			#	direction_x = 0
		#speed_range = 1000 #Maximum minus minimum speed. Yes we could just put 1600, fuck you
		
		## We're going to map our speed, inversely and exponentially, to our dampening value.
		## Ideally, this means that as we gain speed, we'll smooth out our flight
		## And as we slow down, we'll get closer to stalling.
		
		## So first, normalize our current speed by dividing it over our slow_speed.
		fd_dampen = current_speed / GlobalData.terminal_velocity #slow_speed
		if fd_dampen > 1.0:
			fd_dampen = 1.0
		#print("-----------------------------------------------------")
		#print("Normalized Speed: ", fd_dampen)
		## Then we invert the value,
		fd_dampen = (fd_dampen * -1) + 1
		#print("Inverted: ", fd_dampen)
		## Now we exponentially map it between 0 and 1
		fd_dampen = pow(fd_dampen,3)
		#print("Squared: ", fd_dampen)
		## And finally we convert it to our dampening range.
		fd_dampen *= (maximum_damp - minimum_damp) + minimum_damp
		#fd_dampen *= 0.025
		#print("Converted Dampen Value: ", fd_dampen)
		
		
		## Here, we essentially map our current speed to our dampening value, inversely and linearly.
		## So, as our speed goes up, the dampening value goes down.
		dampen_range = maximum_damp - minimum_damp
		#fd_dampen = ((((current_speed * dampen_range) / speed_range) + minimum_damp) * -1) + maximum_damp
		#print(fd_dampen)
		#fd_dampen = pow(fd_dampen,3)
		#fd_dampen = dampen_base
		if is_gliding:
		#	fd_dampen = dampen_glide
			fd_dampen *= 0.15
		#	pass
			#fd_dampen = 0.25 / ((distance_moved * distance_moved))
			#print("Alternative dampen changing: ", fd_dampen)
		if fd_dampen < minimum_damp:
			fd_dampen = minimum_damp
		if fd_dampen > maximum_damp:
			fd_dampen = maximum_damp
		#print("Dampen: ", fd_dampen)
		#print("Flight Direction A1: ", flight_direction)
		flight_direction.y += fd_dampen
		#print("Flight Direction modified: ", flight_direction)
		#print(flight_direction.y + flight_direction.x)
		#print("Flight Direction X, Modified:", direction_x * (76 / distance_moved))
		#flight_direction = flight_direction.normalized()
		
		## Allowing a bit of flapping if our player is merely holding directional keys.
		if current_speed <= max_fly_speed and is_gliding:
			var force = Vector2(direction_x,direction_y).normalized() * 0.25
			force.y *= 1.25
			#print(force)
			apply_force(force)
			#flight_direction.y -= fd_dampen#abs(direction_x) * 0.005
			#if flight_direction.y > 1:
			#	flight_direction.y = 1.0
			#if flight_direction.y < -1:
			#	flight_direction.y = -1.0
			
		if Input.is_action_just_pressed("Dive"):
			if not GlobalData.option_hold_to_dive:
				if is_gliding == false:
					is_gliding = true
					is_hovering = false
				else:
					is_gliding = false
		if Input.is_action_pressed("Dive"):
			if GlobalData.option_hold_to_dive:
				is_gliding = false
		if Input.is_action_just_released("Dive"):
			if GlobalData.option_hold_to_dive:
				is_gliding = true
				is_hovering = false
	else:
		is_hovering = false
		is_gliding = false
		if Input.is_action_pressed("Sprint"):
			is_running = true
			
	## And here's the same thing for Hovering
	#if GlobalData.hover_unlocked:
	if Input.is_action_just_pressed("Hover"):
		## If hovering isn't unlocked, then we need to exceed the Slow Speed in order to initiate Hovering to slow down.
		if GlobalData.hover_unlocked or current_speed >= 500:
			if not GlobalData.option_hold_to_hover:
				if is_hovering == true:
					is_hovering = false
				else:
					is_hovering = true
					is_gliding = false
	if GlobalData.hover_unlocked:
		if Input.is_action_pressed("Hover"):
			if GlobalData.option_hold_to_hover:
				is_hovering = true
				is_gliding = false
		if Input.is_action_just_released("Hover"):
			if GlobalData.option_hold_to_hover:
				is_hovering = false
	
	## New test: a "immediately go down" button
	#if Input.is_action_pressed("begin_landing"):
	#	flight_direction.y += 0.05
	
	
	## Stop hovering if we don't have hovering unlocked *and* we're not going fast enough.
	#if not GlobalData.hover_unlocked and is_hovering:
		#if current_speed <= (stall_speed * 1.5):
			#is_hovering = false
			#if GlobalData.option_dive_leave:
				#is_gliding = false
			#else:
				#is_gliding = true
	
	if is_hovering and not is_grounded:
		is_flying = true
	
	## If our wings are out, it's a bit harder to make sharp turns. But if they're in, we can make sharp turns!
	if is_hovering:
		turn_radius = turn_radius_base * 4
	elif is_gliding:
		turn_radius = glide_turn_radius
	else:
		turn_radius = turn_radius_base
		
	## This is where we use our turning radius. We incrementally will be adding this value to
	## our Flight Direction every tick, which will go against the gravity that constantly pushes it down.
	#print("Flight Direction C1: ", flight_direction)
	flight_direction += Vector2(direction_x,direction_y) * turn_radius
	#print("Flight Direction C2: ", flight_direction)
	## Oh and then we make sure that we don't actually go above 1 for either value because that would lead to ~problems~!
	flight_direction = flight_direction.normalized()
	#flight_direction = linear_velocity
	#print("Flight Direction C3: ", flight_direction)
	
	## This is our jump! If we flap once, it's just a jump. If we flap twice, and we're not on the ground, we start flying!	
	if just_jumped:
		if not is_flying: #not is_grounded
			if flight_direction.y > 0:
				flight_direction.y *= -1 - takeoff_speed
				#print("Flight Direction B2: ", flight_direction)
			#jump_strength += 40.0
			wingbeat()
			is_flying = true
			is_gliding = true
			#is_grounded = false
			
			if GlobalData.option_hover_leave:
				is_hovering = true
			elif GlobalData.option_dive_leave:
				is_gliding = false
			
		## If we're hovering, manually set flight_direction so that we have an easy transition
		elif is_hovering:
			is_hovering = false
			if GlobalData.option_dive_leave:
				is_gliding = false
			else:
				is_gliding = true
			wingbeat()
	
	if is_grounded:
		is_flying = false
		wingbeat_afterburner = 0.0
	
	if not is_flying and not is_grounded:
		if distance_moved > 3 or just_jumped:
			is_flying = true
			if not GlobalData.option_dive_leave:
				is_gliding = true
			flight_direction = linear_velocity.normalized()
			#print("Flight Direction B3: ", flight_direction)
		#else:
			#print("Caught!")
	
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
		linear_velocity = linear_velocity.clamp(Vector2(-GlobalData.terminal_velocity,-GlobalData.terminal_velocity),Vector2(GlobalData.terminal_velocity,GlobalData.terminal_velocity))
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
@export var stored_jump_multiplier = 1.0
@export var jump_strength_base = 2.0
@export var max_jump_strength = 4.0
@export var afterburner_multiplier = 0.45
@export var afterburner_duration_multiplier = 0.97
@export var wingbeat_reset_num = 5

var afterburner_amount = 6.0
var wingbeat_direction = Vector2()
var wingbeat_slow_amount = 0.2 # Maximum: 0.3 Minimum: 0.15
var wingbeat_slow_max = 0.25
var wingbeat_slow_min = 0.12

func wingbeat():
	#print("Stored Jump: ", stored_jump)
	recent_jump_strength = stored_jump
	## Lifting us up ever so slightly if we aren't directionally moving
	if not direction_x and flight_direction.y < 0.4:
		flight_direction.y -= (stored_jump-jump_strength_base) / 15
	#	print("Flight Direction B4: ", flight_direction)
	
	## Otherwise, depending on the strength of the jump, if we're moving,
	## Try and face that direction.
	if is_gliding and (direction_y or direction_x):
		wingbeat_direction = flight_direction
		## Only try and slow down if we're facing opposite directions of where we're going.
		if (direction_x and flight_direction.x > 0) or (direction_x and flight_direction.x < 0):
			wingbeat_direction.x = direction_x
		if (direction_y and flight_direction.y > 0) or (direction_y and flight_direction.y < 0):
			wingbeat_direction.y = direction_y
			
		wingbeat_direction = wingbeat_direction.normalized()
		#print(flight_direction)
		#apply_force(Vector2(direction_x,direction_y).normalized()*10)
		print(stored_jump)
		#Converting our Stored Jump into wingbeat_slow
		wingbeat_slow_amount = (((stored_jump - wingbeat_slow_min) * (wingbeat_slow_max - wingbeat_slow_min)) / (max_jump_strength - jump_strength_base)) + wingbeat_slow_min
		flight_direction = flight_direction.lerp(wingbeat_direction,wingbeat_slow_amount)
		print(jump_strength / max_jump_strength)
		#print(flight_direction)
	
	stored_jump *= stored_jump_multiplier
	var wingbeat_force = 0.0
	
	if current_speed < GlobalData.terminal_velocity:
		## Adding an "afterburner" to continually apply force after we do a wingbeat.
		wingbeat_afterburner = (stored_jump * afterburner_amount)
		#print("Afterburner: ", wingbeat_afterburner)
		
		wingbeat_force = (wingbeat_strength * stored_jump)# - speed_reduction
		print("Wingbeat Force: ", wingbeat_force)
		if current_speed > (GlobalData.terminal_velocity * 0.5):
			wingbeat_force *= 0.5
			wingbeat_afterburner *= 0.5
		#print("Speed-reduced Wingbeat Force: ", wingbeat_force)
		current_speed += wingbeat_force
	
	if current_speed > GlobalData.terminal_velocity:
		current_speed = GlobalData.terminal_velocity
	
	on_wingbeat_cooldown = true
	
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
	if is_gliding:
		if flight_direction.y < 0:
			gravity_scale = grav_scale_default / 1.5
		else:
			gravity_scale = grav_scale_default * 1.2
	else:
		if flight_direction.y < 0:
			gravity_scale = grav_scale_default / 2.0
		else:
			gravity_scale = grav_scale_default * 1.5
	pass


## Flying
var directional_force = Vector2(0,0)
func fly():
	if just_jumped and current_speed <= GlobalData.terminal_velocity and wingbeat_afterburner < wingbeat_reset_num:# and not on_wingbeat_cooldown:
		wingbeat()
		#print("Continue")
	## Adding our afterburner force. This'll slowly go down long after we do the wingbeat, but it's to push us further for a bit longer.
	if wingbeat_afterburner > 1:
		wingbeat_afterburner *= afterburner_duration_multiplier
		current_speed += wingbeat_afterburner * afterburner_multiplier
	if current_speed <= 30:
		flight_direction.y = 1
	apply_momentum()

## Hovering
func hover(max_speed,acceleration):
	if is_climbing and is_running:
		max_speed *= 1.2
		acceleration *= 1.2
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
	var hover_decceleration = 1 + (acceleration / 5750.0)
	if direction_x == 0 and direction_y == 0:
		linear_velocity /= hover_decceleration
	else:
		if (-direction_x > 0 and linear_velocity.x > 0) or (-direction_x < 0 and linear_velocity.x < 0):
			linear_velocity.x /= hover_decceleration
		if (-direction_y > 0 and linear_velocity.y > 0) or (-direction_y < 0 and linear_velocity.y < 0):
			linear_velocity.y /= hover_decceleration
	
	# Steering Radius
	linear_velocity += linear_velocity.direction_to(Vector2(0,0)) * 15

## Climbing
func check_climb():
	#print("checking climb")
	if climb_detector.is_colliding() and abs(direction_x) > 0.2:
		is_climbing = true
		is_flying = false
		is_hovering = false
	pass

func climb():
	hover(max_run_speed,hover_speed)

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
		var damage = snappedf(-distance_moved / 2,1.0)
		resources.health_update(damage)
	pass # Replace with function body.
