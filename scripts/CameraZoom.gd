extends Camera2D

#GOOD ZOOM DISTANCES:
# 5x5
# 

@export_category("Follow_Character")
var zoomSpeed = 1.2

@export var cam_marker : Node2D
@onready var player = get_parent().get_node("dragon")

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
var zoom_levels = [defaultZoomLevel,defaultZoomLevel / 1.7,defaultZoomLevel / 2,defaultZoomLevel / 3]
var zoom_dist_nodes = []
var current_zoom_level = GROUND

var maxZoom_fly = 0.7

var default_weight = 0.005
var weight = default_weight

func _ready():
	current_zoom_level = GROUND
	#weight = float(smoothing_distance) / 5000
	for node in player.get_children():
		if node.is_in_group("cam_zoom_lvl"):
			#print(node.name)
			zoom_dist_nodes.append(node)
	#print(zoom_dist_nodes)
	#print(zoom_levels[GROUND])

## Dynamic Zoom, but only if we're looking
#func _input(event):	
	#if event is InputEventMouseButton and cam_marker.is_looking:
		##weight = 1.0
		#print("--------------------START----------------")
		#print("Before calc: ", zoom)
		#print("Factor: ", zoomSpeed)
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#print("ZOOM IN!")
			#zoom *= Vector2(zoomSpeed,zoomSpeed)
			#print("After calc: ", zoom)
			#print("Max Zoom we can't go below: ", zoom_levels[GROUND])
			#if zoom.x > zoom_levels[GROUND]:
				#zoom = set_zoom_level(zoom_levels[GROUND])
		#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#print("ZOOM OUT!")
			#zoom /= Vector2(zoomSpeed,zoomSpeed)
			#print("After calc: ", zoom)
			#if zoom.x < zoom_levels[MAX]:
				#zoom = set_zoom_level(zoom_levels[MAX])
		#print("Final Zoom: ", zoom)

var direction = Vector2()
var anticipated_direction = Vector2(0.0,0.0)
var held_count = Vector2()
var max_hold = 50.0
var max_hold_y = max_hold / 1.5

var new_zoom : Vector2
@warning_ignore("unused_parameter")
func _process(delta):
	#print("Screen size: ", get_viewport().get_visible_rect().size)
	if player != null:
		#check_zoom()
		max_hold = player.distance_moved * 1.5
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
		if not cam_marker.is_looking:
			#print("Resetting Zoom!")
			zoom = lerp(zoom, new_zoom, weight)
		#print(zoom)
		
		var camera_position : Vector2
		var camera_target : Vector2
		
		camera_target = cam_marker.global_position
		
		if smoothing_enabled:
			var smoothing_weight = pow(log(1.2),2)
			#position = lerp(position, new_position, pow(-weight*delta,3))
			#print("Weight: ", weight)
			#print("Calculated Weight: ", pow(-weight*delta,2))
			camera_position = lerp(global_position, camera_target, smoothing_weight)
		else:
			camera_position = camera_target
		
		global_position = camera_position
		check_zoom()

func set_zoom_level(level):
	return Vector2(level,level)

func check_zoom() -> void:
	if not cam_marker.is_looking:
		#print("Resetting Zoom!")
		defaultZoomLevel = get_viewport().get_visible_rect().size.x / 2800
		#zoom_levels = [defaultZoomLevel * 1.5,defaultZoomLevel / 1.7,defaultZoomLevel / 3,defaultZoomLevel / 6]
		zoom_levels = [defaultZoomLevel * 1.25,defaultZoomLevel / 1.7,defaultZoomLevel / 2,defaultZoomLevel / 3]
		#print(defaultZoomLevel)
		var i = -1
		for node in zoom_dist_nodes:
			i += 1
			#print(node.get_overlapping_bodies())
			if node.get_overlapping_bodies().size() > 0:
				current_zoom_level = i
				break
			else:
				current_zoom_level = MAX
		##ZOOM CHANGING
		new_zoom = set_zoom_level(zoom_levels[current_zoom_level])
