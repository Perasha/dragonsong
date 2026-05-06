extends Camera2D

#GOOD ZOOM DISTANCES:
# 5x5
# 

@export_category("Follow Character")
var zoomSpeed = 1.2

@export var cam_marker : Node2D
@onready var dragon_node = get_parent().get_node("dragon")

@export var camera_3d : Camera3D

@export_category("Camera Smoothing")
@export var smoothing_enabled : bool
#@export_range(1,100) var smoothing_distance : int = 8
@export var defaultZoomLevel = 0.6 #0.65
@export var default_zoom_factor = 3000
@onready var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
@onready var margin_debug = get_node("Margin")
@onready var dragon_pointer_debug = get_node("DragonPointer")
var zoom_factor = 3000
var minZoom = 0.05
var maxZoom = 1.0
var maxHeight = 10000

# Zoom levels 0 - 2
enum {GROUND, NEAR, FAR, MAX}
#var zoom_levels_base = [defaultZoomLevel,defaultZoomLevel / 1.7,defaultZoomLevel / 3,defaultZoomLevel / 4.5]
# 1, 1.7, 3, 4.5
var zoom_levels = [1,1.7,3,5.5]
var zoom_dist_nodes = []
var current_zoom_level = GROUND

var maxZoom_fly = 0.7

@export var default_weight = 0.005
var weight = default_weight

@export var smoothing_weight_modifier = 1.0

#@export_category("3D Tracking")
#@export var head_target : Node3D
var screen_inset_rectangle: Rect2

func _ready():
	current_zoom_level = GROUND
	#weight = float(smoothing_distance) / 5000
	for node in dragon_node.get_children():
		if node.is_in_group("cam_zoom_lvl"):
			#print(node.name)
			zoom_dist_nodes.append(node)
	#print(zoom_dist_nodes)
	#print(zoom_levels[GROUND])
	get_tree().get_root().size_changed.connect(update_window)
	#screen_inset_rectangle = Rect2(Vector2.ZERO, viewport_dimensions).grow(-10)
	#margin_debug.shape.size = screen_inset_rectangle.size / zoom

var direction = Vector2()
var anticipated_direction = Vector2(0.0,0.0)
var held_count = Vector2()
var max_hold = 50.0
var max_hold_y = max_hold / 1.5

var new_zoom : Vector2

var is_looking = false

@export_category("Edge Margins")
@export var on_screen_offset: Vector2 = Vector2(0.5, -5.0)
@export var screen_margin = 50.0
@export var smoothing_speed: float = 8.0
@export var margin_multiplier = 1.0

var screen_constraint = Vector2(0,0)

@warning_ignore("unused_parameter")
func _process(delta):
	update_margin()
	#camera_3d.position.x = position.x
	#camera_3d.position.y = position.y
	#print("Screen size: ", get_viewport().get_visible_rect().size)
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
	
	
	zoom = lerp(zoom, new_zoom, weight)
	#print(zoom)
	#margin_debug.shape.size = viewport_dimensions / new_zoom
	
	var camera_position : Vector2
	var camera_target : Vector2
	
	camera_target = cam_marker.global_position
	
	if smoothing_enabled:
		var smoothing_weight = (dragon_node.current_speed / GlobalData.terminal_velocity) * smoothing_weight_modifier#0.03#pow(log(1.2),2)
		#print("Smoothing weight: ", smoothing_weight)
		if smoothing_weight < 0.03: 
			smoothing_weight = 0.03
		#print("Smoothing weight: ", smoothing_weight)
		camera_position = lerp(global_position, camera_target, smoothing_weight)
	else:
		camera_position = camera_target
	
	## Now; as the zoom level DECREASES, we need the margin to INCREASE.
	#screen_constraint = (screen_margin / (1.0 + zoom.x) * margin_multiplier) + abs(dragon_node.position)
	#print("Screen Constraint: ", screen_constraint)
	#print("Camera Target: ", camera_target)
	#print("Cam Target + Screen Constraint: ", screen_constraint + abs(camera_target))
	#camera_position = camera_position.clamp(-screen_constraint,screen_constraint)
	
	global_position = camera_position
	if is_looking:
		current_zoom_level = MAX
	else:
		check_zoom()
	##ZOOM CHANGING
	new_zoom = set_zoom_level(defaultZoomLevel / zoom_levels[current_zoom_level])
	#print((get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()).affine_inverse())
	#var viewport_conversion = (get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()).affine_inverse()
	#print(get_viewport().get_canvas_transform())
	#print(get_viewport().get_visible_rect().size)
	#print(get_viewport().global_canvas_transform)
	#margin_debug.shape.size = (get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()).affine_inverse()# * screen_pos#viewport_dimensions# / new_zoom

func set_zoom_level(level):
	return Vector2(level,level)

func update_window():
	defaultZoomLevel = get_viewport().get_visible_rect().size.x / 2800

#var clamped_distance = 0.0
func update_margin():
	screen_inset_rectangle = Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).grow(-screen_margin)
	screen_inset_rectangle.size = screen_inset_rectangle.size / zoom
	screen_inset_rectangle.size.y += screen_margin
	margin_debug.shape.size = screen_inset_rectangle.size
	dragon_pointer_debug.target_position = -(global_position - dragon_node.global_position)
	#print(margin_debug.shape.size)
	#test_point = dragon_pointer_debug.target_position - (screen_inset_rectangle.size / 2)
	#print("Screen Inset Rectangle: ", screen_inset_rectangle, " Target Position: ", dragon_pointer_debug.target_position)
	#if not screen_inset_rectangle.has_point(dragon_pointer_debug.target_position + (screen_inset_rectangle.size / 2)):
		## Normalize the distance_lag vector. 
		#cam_marker.max_distance_lag = pow(dragon_pointer_debug.target_position.x,2) + pow(dragon_pointer_debug.target_position.y,2)
		#cam_marker.max_distance_lag = sqrt(cam_marker.max_distance_lag)
		#cam_marker.is_constrained = true
	#else:
		#cam_marker.is_constrained = false
	#print("Dragon Position: ", dragon_node.position, "Debug Target Position: ", dragon_pointer_debug.target_position)

func check_zoom() -> void:
	#var i = -1
	#for node in zoom_dist_nodes:
		#i += 1
		#if node.get_overlapping_bodies().size() > 0:
			#current_zoom_level = i
			#break
		#else:
			#current_zoom_level = FAR#MAX
	##ZOOM CHANGING
	if dragon_node.get_node("Ground").get_overlapping_bodies().size() > 0:
		current_zoom_level = GROUND
	else:
		current_zoom_level = FAR
	new_zoom = set_zoom_level(defaultZoomLevel / zoom_levels[current_zoom_level])
