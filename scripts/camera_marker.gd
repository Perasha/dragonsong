extends Node2D

#@export var player_visibility : VisibleOnScreenNotifier2D
@onready var dragon_node = get_parent()
@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node = get_parent().get_parent().get_node("Camera2D")
@onready var raycast_anchor = get_parent().get_node("RayCastAnchor")
@onready var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
@onready var screen_margin = viewport_dimensions
var screen_constraint = Vector2(0,0)
@export var look_marker : Sprite2D

var current_pos = Vector2()
var prev_pos = Vector2()
var dist_moved = 0.1

## Apply Zoom Multiplier
func zoom_multipler():
	return camera_node.zoom.x / camera_node.defaultZoomLevel

#var screen_margin = Vector2()
#var duration_step = 2.0
var new_position = Vector2(0,0)
var is_looking = false
#var current_anchor = Vector2(0,0)

## Ground, Near, Far, Max
#var distance_limit = [Vector2(500,300),Vector2(1000,500),Vector2(2000,1500),Vector2(3000,2000)]
#var distance_limit = [Vector2(500,300),Vector2(500,300),Vector2(500,300),Vector2(500,300)]

@export var raycast_max_angle = 45.0

## By adjusting this value, we essentially make sure that our character doesn't ever leave the frame.
@export var margin_multiplier = 1.0
@export var distance_lag_multiplier = 1.0
var anchor = Vector2(0,0)
var speed_fraction = 1.0
enum {GROUND, NEAR, FAR, MAX}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var weight = 0.1


## Screen Position Calibration
#var ci: CanvasItem = self
#@onready var root: Window = ci.get_tree().root

#var ci_screen_pos: Vector2 

func _process(delta: float) -> void:
	prev_pos = current_pos
	current_pos = position
	
	if GlobalData.option_hold_to_look:
		if Input.is_action_pressed("look"):
			is_looking = true
		else:
			is_looking = false
	else:
		if Input.is_action_just_pressed("look"):
			if is_looking == true:
				is_looking = false
			else:
				is_looking = true
	
	if look_marker.visible and is_looking == false:
		look_marker.hide()
	elif not look_marker.visible and is_looking == true:
		look_marker.show()
	
	if is_looking:
		weight = 0.01
		#print("looking!")
		#print(position)
		#print(get_viewport().get_mouse_position())
		#var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
		new_position = (get_viewport().get_mouse_position() - (viewport_dimensions / 2))
		if camera_node.current_zoom_level == GROUND:
			new_position *= 1.5
		elif camera_node.current_zoom_level == NEAR:
			new_position *= 2
		elif camera_node.current_zoom_level == FAR:
			new_position *= 3
		else:
			new_position *= 5
		#print(new_position)
		#weight = 0.05
	
	
	#elif dragon_node.is_flying:
	#var distance_threshold = viewport_dimensions / (camera_node.zoom * 2)
	#distance_threshold.y *= 1.5
	#if dragon_node.current_speed < 30:
	#	new_position = Vector2(0,0)
	#	weight = 0.01
	#else:
	#var distance_lag = Vector2(dragon_node.current_speed / 1.05, dragon_node.current_speed / 1.01) * distance_lag_multiplier# * (camera_node.zoom.x * distance_lag_multiplier)
	var distance_lag = dragon_node.current_speed / zoom_multipler()#camera_node.position.distance_to(dragon_node.position) + (dragon_node.current_speed)
	#print(distance_lag)
		
	new_position = dragon_node.flight_direction * distance_lag
	#print("Only Distance Lag:", new_position)
	weight = 0.008
	#weight = ((dragon_node.current_speed / GlobalData.terminal_velocity) / 50)# + 0.01
	#weight = clamp(weight,0.009,0.05)
		#print("Curren", dragon_node.current_speed)
	#print("Weight: ", weight)
		
	## Auto-look
	## If our Zoom level is high enough AND we're out of bounds of the new threshold we set, 
	## Find an Anchor within a Distance
	## Move our marker to that Anchor
		
	if camera_node.current_zoom_level == MAX and raycast_anchor.is_colliding() and dragon_node.is_flying:
		
		## Getting our angle for the raycaster; the higher speed, the more we angle it outwards
		## Get this by dividing our Current Speed by Terminal Velocity
		## Then multiplying that by our maximum angle,
		## And getting its direction by multiplying that by our flight_direction
		speed_fraction = dragon_node.current_speed / GlobalData.terminal_velocity
		if dragon_node.flight_direction.x > 0: 
			speed_fraction *= -1
		raycast_anchor.rotation_degrees = speed_fraction * raycast_max_angle
		
		raycast_anchor.force_raycast_update()
		anchor = raycast_anchor.get_collision_point()
		new_position.y = to_local(anchor).y
	elif not dragon_node.is_flying:
		#weight = 0.009
		new_position.y -= 200
		
	## Constraining our new_position to the margins we set!
	## We probably don't need to, but I want to manually normalize our new_position to our margin_constraint
	## So, for X and for Y, (vector.x / vector's length) multiplied by our margin value!
	## Dividing the X by the vector's total length is how we normalize. 
	## Then, we just take that fraction and multiply it by the length that we actually want. And we can do that in two directions!
	## This hypothetically should create an oval, otherwise it'd make a circle :D
	
	## Now; as the zoom level DECREASES, we need the margin to INCREASE.
	screen_constraint = screen_margin / (1.0 + camera_node.zoom.x) * margin_multiplier
	#print("Screen Constraint: ", screen_constraint)
	
	#new_position = Vector2((new_position.x / new_position.length()) * screen_constraint.x,(new_position.y / new_position.length()) * screen_constraint.y)
	new_position = new_position.clamp(-screen_constraint,screen_constraint)
	#print("Distance Threshold: ", distance_threshold)
	#print("New Position: ", new_position)
		
	#else:
	#	new_position = Vector2(0,0)
	#	weight = 0.05
	
	position = lerp(position, new_position, weight)
	
	dist_moved = prev_pos.distance_to(current_pos)
	#print(dist_moved * 0.01)
