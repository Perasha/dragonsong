extends Node2D

#@export var player_visibility : VisibleOnScreenNotifier2D
@onready var dragon_node = get_parent()
#@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node = get_parent().get_parent().get_node("Camera2D")
#@onready var raycast_anchor = get_parent().get_node("RayCastAnchor")
@onready var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
@export var screen_margin_multiplier = 1.0
@onready var screen_constraint = Vector2(viewport_dimensions.x,viewport_dimensions.y)
#var screen_constraint = Vector2(0,0)
@export var look_marker : Sprite2D
var is_constrained = false

var current_pos = Vector2()
var prev_pos = Vector2()
var dist_moved = 0.1
var new_position = Vector2(0,0)
#var is_looking = false

#@export var raycast_max_angle = 45.0

## By adjusting this value, we essentially make sure that our character doesn't ever leave the frame.
#@export var margin_multiplier = 1.0
#@export var distance_lag_multiplier = 1.0
#var anchor = Vector2(0,0)
#var speed_fraction = 1.0
enum {GROUND, NEAR, FAR, MAX}

var max_distance_lag = 5000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var weight = 0.1
#var screen_constraint = Vector2(2500,1300)
# FAR distance: 0.2 Zoom Level, 2000 x 1500, Screen Dimensions: 1152x648
# 1152 at 0.2 -> 2000

func _process(delta: float) -> void:
	#print("CAM MARKER PROCESS START -----------------------------------")
	#print("HI hello there this is a test!")
	#print("Cam Marker position: ", position)
	prev_pos = current_pos
	current_pos = position
	#print(zoom_multipler())
	var distance_lag = snappedf(dragon_node.current_speed / zoom_multipler(),0.01)
	#print("Distance Lag: ", distance_lag)
	#snappedf(3.14159, 0.01)
	if is_constrained:
		distance_lag = max_distance_lag
	## That distance lag is a vector line with a length.
	## We can also draw a line from the center of our camera to the dragon_node
	## Then, we can test to see if the position of dragon_node is within our screen_inset_rectangle
	## Or, rather, if not the actual position of the dragon, just the result of the vector we chose.
	
	#print("Current Distance Lag: ", distance_lag)
	#print("Maximum Distance Lag: ", max_distance_lag)
	#print("Flight direction: ", dragon_node.flight_direction)
	
	#screen_constraint = (Vector2(viewport_dimensions.x,viewport_dimensions.y) / zoom_multipler()) * screen_margin_multiplier
	#screen_constraint += Vector2(viewport_dimensions.x,viewport_dimensions.y)
	#if (dragon_node.flight_direction.x + dragon_node.flight_direction.y > 2) or (dragon_node.flight_direction.x + dragon_node.flight_direction.y < 2):
	#	new_position = Vector2(0,0)
	#	print("Exception caught")
	#else:
	new_position = dragon_node.flight_direction * distance_lag
	#weight = 0.008
	weight = dragon_node.fd_dampen + (.008 - dragon_node.fd_dampen)
	if not dragon_node.is_flying:
		new_position.y -= 200
	
	## This is what clamps our position to be within the screen margin we designate.
	new_position = new_position.clamp(-(camera_node.screen_inset_rectangle.size / 2),(camera_node.screen_inset_rectangle.size / 2))
	#("New Position", new_position)
	position = lerp(position, new_position, weight)
		
	dist_moved = prev_pos.distance_to(current_pos)

## Apply Zoom Multiplier
func zoom_multipler():
	return camera_node.zoom.x / camera_node.defaultZoomLevel
