extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -800.0

var is_gliding = false
@onready var jump_timer = get_node("JumpTimer")
@onready var sprite = get_node("Sprite2D")
var has_jumped = false
var is_diving = false

var last_velocity = Vector2(0.0,0.0)

func _physics_process(delta: float) -> void:
	#print("Last Velocity: ", last_velocity)
	# Handle jump
	
	
	# Next plans:
	# If we're on the ground, give VERTICAL velocity
	# If we're in the air, we just want to INCREASE our current velocity, whatever that may be.
	# Or rather, if we're holding a direction, give just a bit of verticality and just increase the 
	
	if Input.is_action_just_pressed("dive"):
		is_diving = true
	if Input.is_action_just_released("dive"):
		is_diving = false
		
	# When we hit JUMP, and we're holding a direction, multiply the direction.
	if Input.is_action_just_pressed("ui_accept"):
		is_gliding = true
		has_jumped = true
		jump_timer.start()


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if has_jumped:
			velocity.x *= 1.5
			velocity.y = JUMP_VELOCITY / 4
	else:
		if has_jumped:
			velocity.y = JUMP_VELOCITY / 2
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.x > 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	#print("Current velocity: ", velocity)
	
	
	# Detect Gliding
	if Input.is_action_just_released("ui_accept"):
		is_gliding = false
		has_jumped = true
		jump_timer.start()
	
	
	# Slowing descent if gliding, otherwise apply gliding
	if is_gliding and not has_jumped:
		print("Gliding!")
		velocity.y = 50
	elif is_diving:
		print("Gravity!")
		velocity += (get_gravity() * delta) * (get_gravity() * delta)
	elif not is_diving:
		print("Slow descent")
		velocity += (get_gravity() * delta)
	
	#print("Final velocity: ", velocity)
	move_and_slide()
	last_velocity = velocity
	

func _on_jump_timer_timeout() -> void:
	has_jumped = false
	print("Jump timer ending!")
