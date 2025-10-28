extends Camera2D

#GOOD ZOOM DISTANCES:
# 5x5
# 

@export_category("Follow_Character")
var zoomSpeed = 1.2

@export var player : RigidBody2D

@export_category("Camera Smoothing")
@export var smoothing_enabled : bool
@export_range(1,100) var smoothing_distance : int = 8
@export var defaultZoomLevel = 0.65
@export var default_zoom_factor = 3000
var zoom_factor = 3000
var minZoom = 0.05
var maxZoom = 1.0
var maxHeight = 10000

# Zoom levels 0 - 2
enum {GROUND, NEAR, FAR, MAX}
var zoom_levels = [defaultZoomLevel,defaultZoomLevel / 1.5,defaultZoomLevel / 3,defaultZoomLevel / 4]
var zoom_dist_nodes = []
var current_zoom_level = GROUND

var maxZoom_fly = 0.7

var weight : float

func _ready():
	current_zoom_level = GROUND
	weight = float(smoothing_distance) / 500
	for node in get_children():
		if node.get_class() == "Area2D":
			#print(node.name)
			zoom_dist_nodes.append(node)
	#print(zoom_dist_nodes)
	#print(zoom_levels[GROUND])

func _input(event):	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom *= Vector2(zoomSpeed,zoomSpeed)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom /= Vector2(zoomSpeed,zoomSpeed)

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if player != null:
		##ZOOM CHANGING
		var new_zoom = Vector2(zoom_levels[current_zoom_level],zoom_levels[current_zoom_level])
		#print(zoom_levels[current_zoom_level])
		#new_zoom.x = zoom_levels[current_zoom_level]
		#new_zoom.y = new_zoom.x
		zoom = lerp(zoom, new_zoom, 0.01)
		#print(zoom)
		
		var camera_position : Vector2
		var camera_target : Vector2
		
		if player.is_flying:
			#camera_target = mouse_pos + player.global_position
			camera_target = player.global_position
			pass
		else:
			camera_target = player.global_position
		
		if smoothing_enabled:
			camera_position = lerp(global_position, camera_target, weight)
			#camera_position = lerp(global_position, player.global_position + camera_target_beyond, weight)
		else:
			camera_position = camera_target
		
		global_position = camera_position


func _on_check_zoom_timeout() -> void:
	print('Timeout!')
	var i = -1
	for node in zoom_dist_nodes:
		i += 1
		#print(node.get_overlapping_bodies().size())
		if node.get_overlapping_bodies().size() > 1:
			current_zoom_level = i
			break
		else:
			current_zoom_level = MAX
	print("Level: ", i, ",", current_zoom_level)
	pass # Replace with function body.
