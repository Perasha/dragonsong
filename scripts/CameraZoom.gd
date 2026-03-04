extends Camera2D

#GOOD ZOOM DISTANCES:
# 5x5
# 

@export_category("Follow Character")
var zoomSpeed = 1.2

@export var cam_marker : Node2D
@onready var dragon_node = get_parent().get_node("dragon")

@export_category("Camera Smoothing")
@export var smoothing_enabled : bool
#@export_range(1,100) var smoothing_distance : int = 8
@export var defaultZoomLevel = 0.6 #0.65
@export var default_zoom_factor = 3000
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

@export_category("Edge Margins")
@export var on_screen_offset: Vector2 = Vector2(0.5, -5.0)
@export var screen_margin: float = 4.0
@export var smoothing_speed: float = 8.0

@warning_ignore("unused_parameter")
func _process(delta):
	#print("Screen size: ", get_viewport().get_visible_rect().size)
	if dragon_node != null:
		#check_zoom()
		max_hold = dragon_node.distance_moved * 1.5
		#Here, we're getting our direction inputs again.
		# We use this to add to a hold_count value, 
		# and essentially slowly push our camera in that direction if it's held there.
		direction.x = Input.get_axis("ui_left", "ui_right")
		direction.y = Input.get_axis("ui_up", "ui_down")
		
		#held_count += direction
		held_count += (direction) * 5
		held_count += held_count.direction_to(Vector2(0,0))
		#print(held_count)
		
		if abs(held_count.y) > max_hold_y:
			if held_count.y < 0: held_count.y = -max_hold_y
			else: held_count.y = max_hold_y
		if abs(held_count.x) > max_hold:
			if held_count.x < 0: held_count.x = -max_hold
			else: held_count.x = max_hold
		
		#print(held_count)
		#print("Held Count:", held_count)
		#anticipated_direction = Vector2(1.0,1.0) * (direction * direction)
		#print(direction)
		#print(anticipated_direction)
		##ZOOM CHANGING
		#new_zoom = set_zoom_level(zoom_levels[current_zoom_level])
		#print(zoom_levels[current_zoom_level])
		#new_zoom.x = zoom_levels[current_zoom_level]
		#new_zoom.y = new_zoom.x
		#if not cam_marker.is_looking:
			#print("Resetting Zoom!")
		zoom = lerp(zoom, new_zoom, weight)
		#print(zoom)
		
		var camera_position : Vector2
		var camera_target : Vector2
		
		camera_target = cam_marker.global_position
		
		#if dragon_node.is_flying:
			#smoothing_enabled = false
		#else:
			#smoothing_enabled = true
		
		if smoothing_enabled:
			var smoothing_weight = (cam_marker.dist_moved * 0.01) * smoothing_weight_modifier#0.03#pow(log(1.2),2)
			if smoothing_weight < 0.03: smoothing_weight = 0.03
			#position = lerp(position, new_position, pow(-weight*delta,3))
			#print("Weight: ", smoothing_weight)
			#print("Calculated Weight: ", pow(-weight*delta,2))
			#print("Distance Behind Dragon: ", position.distance_to(dragon_node.position))
			#print("Distance to Target Position: ", position.distance_to(dragon_node.position))
			camera_position = lerp(global_position, camera_target, smoothing_weight)
		else:
			camera_position = camera_target
		
		global_position = camera_position
		check_zoom()

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
			current_zoom_level = MAX
	##ZOOM CHANGING
	new_zoom = set_zoom_level(defaultZoomLevel / zoom_levels[current_zoom_level])
