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
@onready var screen_margin = viewport_dimensions
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

var direction = Vector2()
var anticipated_direction = Vector2(0.0,0.0)
var held_count = Vector2()
var max_hold = 50.0
var max_hold_y = max_hold / 1.5

var new_zoom : Vector2

var is_looking = false

@export_category("Edge Margins")
@export var on_screen_offset: Vector2 = Vector2(0.5, -5.0)
#@export var screen_margin: float = 4.0
@export var smoothing_speed: float = 8.0
@export var margin_multiplier = 1.0

var screen_constraint = Vector2(0,0)

@warning_ignore("unused_parameter")
func _process(delta):
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
	
	var camera_position : Vector2
	var camera_target : Vector2
	
	camera_target = cam_marker.global_position
	
	if smoothing_enabled:
		var smoothing_weight = (cam_marker.dist_moved * 0.01) * smoothing_weight_modifier#0.03#pow(log(1.2),2)
		if smoothing_weight < 0.03: smoothing_weight = 0.03
		camera_position = lerp(global_position, camera_target, smoothing_weight)
	else:
		camera_position = camera_target
	
	## Now; as the zoom level DECREASES, we need the margin to INCREASE.
	screen_constraint = (screen_margin / (1.0 + zoom.x) * margin_multiplier)# * dragon_node.position
	print(screen_constraint)
	camera_position = camera_position.clamp(-screen_constraint,screen_constraint)
	
	global_position = camera_position
	if is_looking:
		current_zoom_level = MAX
	else:
		check_zoom()
	##ZOOM CHANGING
	new_zoom = set_zoom_level(defaultZoomLevel / zoom_levels[current_zoom_level])

func set_zoom_level(level):
	return Vector2(level,level)

func update_window():
	defaultZoomLevel = get_viewport().get_visible_rect().size.x / 2800

func check_zoom() -> void:
	var i = -1
	for node in zoom_dist_nodes:
		i += 1
		if node.get_overlapping_bodies().size() > 0:
			current_zoom_level = i
			break
		else:
			current_zoom_level = FAR#MAX
	##ZOOM CHANGING
	new_zoom = set_zoom_level(defaultZoomLevel / zoom_levels[current_zoom_level])
