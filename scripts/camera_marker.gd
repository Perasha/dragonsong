extends Node2D

#@export var player_visibility : VisibleOnScreenNotifier2D
@onready var dragon_node : RigidBody2D = %dragon
#@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node : Camera2D = %Camera2D
@onready var raycast_anchor : RayCast2D = %RayCastAnchor
@onready var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
@export var screen_margin_multiplier = 1.0
#@onready var screen_constraint = Vector2(viewport_dimensions.x,viewport_dimensions.y)
var margin_constraint = Vector2(0,0)
#var screen_constraint = Vector2(0,0)
@export var look_marker : Sprite2D
#var is_constrained = false
var distance_lag = Vector2(0,0)

var is_x_locked = false
var is_y_locked = false

var current_pos = Vector2()
var prev_pos = Vector2()
var dist_moved = 0.1
var new_position = Vector2(0,0)
@export var ground_camera_distance = 200
#var is_looking = false

#@export var raycast_max_angle = 45.0

## By adjusting this value, we essentially make sure that our character doesn't ever leave the frame.
#@export var margin_multiplier = 1.0
#@export var distance_lag_multiplier = 1.0
#var anchor = Vector2(0,0)
#var speed_fraction = 1.0
enum {GROUND, NEAR, FAR, MAX}

#var max_distance_lag = 10000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var weight = 0.1
#var screen_constraint = Vector2(2500,1300)
# FAR distance: 0.2 Zoom Level, 2000 x 1500, Screen Dimensions: 1152x648
# 1152 at 0.2 -> 2000
#var prev_zoom = 0.0
var prev_flight_direction = Vector2(0,0)

func _physics_process(delta: float) -> void:
	is_y_locked = false
	is_x_locked = false
	
	## Adding half the screen_inset_rectangle size to center the rectangle on the position
	margin_constraint = camera_node.screen_inset_rectangle.size / 2
	#print(margin_constraint)
	#distance_lag.x = snappedf(dragon_node.current_speed / zoom_multipler(),0.01)
	distance_lag = Vector2(abs(dragon_node.linear_velocity.x),abs(dragon_node.linear_velocity.y)) / zoom_multipler()
	
	if is_inf(distance_lag.x) or is_inf(distance_lag.y) or is_nan(distance_lag.x) or is_nan(distance_lag.y):
		distance_lag = 1.0
	#else:
		#if distance_lag.x > margin_constraint.x:
			#distance_lag.x = margin_constraint.x
		#if distance_lag.y > margin_constraint.y:
			#distance_lag.y = margin_constraint.y
	#print("Distance lag: ", distance_lag)
	#print((prev_flight_direction + Vector2(1,1)) - (dragon_node.flight_direction + Vector2(1,1)))
	print(prev_flight_direction - dragon_node.flight_direction)
	#print(dragon_node.flight_direction + Vector2(1,1))
	#weight = dragon_node.fd_dampen# + (.004 - dragon_node.fd_dampen)# + (abs(camera_node.zoom.x - prev_zoom) * 40)
	weight = .008
	#weight = (prev_flight_direction - dragon_node.flight_direction) * 10
	## Setting our new_position we want to lerp towards
	new_position = (dragon_node.flight_direction * distance_lag)
	position = lerp(position,new_position,weight)
	
	## Make sure we never clear the margin we set by clamping our position between the margins
	position = position.clamp(-margin_constraint,margin_constraint)
	#prev_zoom = camera_node.zoom.x
	prev_flight_direction = dragon_node.flight_direction
	#dist_moved = prev_pos.distance_to(current_pos)

## Apply Zoom Multiplier
func zoom_multipler():
	return camera_node.zoom.x / camera_node.defaultZoomLevel
