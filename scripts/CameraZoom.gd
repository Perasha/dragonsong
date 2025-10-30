extends Camera2D

#GOOD ZOOM DISTANCES:
# 5x5
# 

@export_category("Follow_Character")
var zoomSpeed = 1.2

@export var follow_target : Node2D
@onready var player = get_parent().get_node("dragon")

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
var zoom_levels = [defaultZoomLevel,defaultZoomLevel / 1.7,defaultZoomLevel / 3,defaultZoomLevel / 6]
var zoom_dist_nodes = []
var current_zoom_level = GROUND

var maxZoom_fly = 0.7

var weight : float

func _ready():
	current_zoom_level = GROUND
	weight = float(smoothing_distance) / 5000
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

var direction = Vector2()
var anticipated_direction = Vector2(0.0,0.0)
var held_count = Vector2()
var max_hold = 50.0
var max_hold_y = max_hold / 1.5

@warning_ignore("unused_parameter")
func _process(delta):
	if player != null:
		check_zoom()
		max_hold = player.distance_moved * 1.5
		#Here, we're getting our direction inputs again.
		# We use this to add to a hold_count value, 
		# and essentially slowly push our camera in that direction if it's held there.
		direction.x = Input.get_axis("ui_left", "ui_right")
		direction.y = Input.get_axis("ui_up", "ui_down")
		
		#held_count += direction
		held_count += (direction) * 5
		held_count -= held_count.direction_to(Vector2(0,0))
		
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
		var new_zoom = Vector2(zoom_levels[current_zoom_level],zoom_levels[current_zoom_level])
		#print(zoom_levels[current_zoom_level])
		#new_zoom.x = zoom_levels[current_zoom_level]
		#new_zoom.y = new_zoom.x
		zoom = lerp(zoom, new_zoom, 0.01)
		#print(zoom)
		
		var camera_position : Vector2
		var camera_target : Vector2
		
		camera_target = follow_target.global_position
		
		if smoothing_enabled:
			var weight = pow(log(1.2),2)
			#position = lerp(position, new_position, pow(-weight*delta,3))
			#print("Weight: ", weight)
			#print("Calculated Weight: ", pow(-weight*delta,2))
			camera_position = lerp(global_position, camera_target, weight)
		else:
			camera_position = camera_target
		
		global_position = camera_position


func check_zoom() -> void:
	#print('Timeout!')
	var i = -1
	for node in zoom_dist_nodes:
		i += 1
		#print(node.get_overlapping_bodies().size())
		if node.get_overlapping_bodies().size() > 1:
			current_zoom_level = i
			break
		else:
			current_zoom_level = MAX
	#print("Level: ", i, ",", current_zoom_level)
	pass # Replace with function body.
