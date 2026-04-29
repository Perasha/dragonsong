extends Node2D

#@export var player_visibility : VisibleOnScreenNotifier2D
@onready var dragon_node = get_parent()
@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node = get_parent().get_parent().get_node("Camera2D")
@onready var raycast_anchor = get_parent().get_node("RayCastAnchor")
@onready var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
@onready var screen_margin = viewport_dimensions
#var screen_constraint = Vector2(0,0)
@export var look_marker : Sprite2D

var current_pos = Vector2()
var prev_pos = Vector2()
var dist_moved = 0.1

## Apply Zoom Multiplier
func zoom_multipler():
	return camera_node.zoom.x / camera_node.defaultZoomLevel

var new_position = Vector2(0,0)
var is_looking = false

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


func _process(delta: float) -> void:
	prev_pos = current_pos
	current_pos = position
	
	var distance_lag = dragon_node.current_speed / zoom_multipler()#camera_node.position.distance_to(dragon_node.position) + (dragon_node.current_speed)
	#print(distance_lag)
	#print(zoom_multipler())
		
	new_position = dragon_node.flight_direction * distance_lag
	weight = 0.008
		
	## Auto-look
	## If our Zoom level is high enough AND we're out of bounds of the new threshold we set, 
	## Find an Anchor within a Distance
	## Move our marker to that Anchor
		
	#if raycast_anchor.is_colliding() and dragon_node.is_flying and camera_node.current_zoom_level == FAR:# and 
		#
		### Getting our angle for the raycaster; the higher speed, the more we angle it outwards
		### Get this by dividing our Current Speed by Terminal Velocity
		### Then multiplying that by our maximum angle,
		### And getting its direction by multiplying that by our flight_direction
		#speed_fraction = dragon_node.current_speed / GlobalData.terminal_velocity
		#if dragon_node.flight_direction.x > 0: 
			#speed_fraction *= -1
		#raycast_anchor.rotation_degrees = speed_fraction * raycast_max_angle
		#
		#raycast_anchor.force_raycast_update()
		#anchor = raycast_anchor.get_collision_point()
		#new_position.y = to_local(anchor).y
	#elif not dragon_node.is_flying:
		#weight = 0.009
		#new_position.y -= 200
	if not dragon_node.is_flying:
		new_position.y -= 200
	## Constraining our new_position to the margins we set!
	## We probably don't need to, but I want to manually normalize our new_position to our margin_constraint
	## So, for X and for Y, (vector.x / vector's length) multiplied by our margin value!
	## Dividing the X by the vector's total length is how we normalize. 
	## Then, we just take that fraction and multiply it by the length that we actually want. And we can do that in two directions!
	## This hypothetically should create an oval, otherwise it'd make a circle :D
		
	## Now; as the zoom level DECREASES, we need the margin to INCREASE.
	#screen_constraint = screen_margin / (1.0 + camera_node.zoom.x) * margin_multiplier
	#new_position = new_position.clamp(-screen_constraint,screen_constraint)
		
	position = lerp(position, new_position, weight)
		
	dist_moved = prev_pos.distance_to(current_pos)
