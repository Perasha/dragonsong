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
@export var defaultZoomLevel = 0.8
var minZoom = 0.15
var maxZoom = 1.0

var maxZoom_fly = 0.3

var weight : float

func _ready():
	weight = float(smoothing_distance) / 200

func _input(event):	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom *= Vector2(zoomSpeed,zoomSpeed)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom /= Vector2(zoomSpeed,zoomSpeed)

func _physics_process(delta):
	if player != null:
		var zoom_factor = 2000
		#print(player.current_speed)
		#print(zoom)
		#print(defaultZoomLevel - ((player.current_speed + 1) / 3000))
		var new_zoom = Vector2(defaultZoomLevel - ((player.current_speed + 1) / zoom_factor),defaultZoomLevel - ((player.current_speed + 1) / zoom_factor))
		if player.is_flying:
			if new_zoom.x > maxZoom_fly: new_zoom.x = maxZoom_fly
			if new_zoom.y > maxZoom_fly: new_zoom.y = maxZoom_fly
			#weight *= 2
		else:
			if new_zoom.x > maxZoom: new_zoom.x = maxZoom
			if new_zoom.y > maxZoom: new_zoom.y = maxZoom
		if new_zoom.x < minZoom: new_zoom.x = minZoom
		if new_zoom.y < minZoom: new_zoom.y = minZoom
		
		zoom = lerp(zoom, new_zoom, 0.01)
		#print(zoom)
		
		var camera_position : Vector2
		
		if smoothing_enabled:
			
			#var camera_target_beyond = player.flight_direction * 500
			#camera_target_beyond.x *= player.current_speed / 500
			#camera_target_beyond.y *= player.current_speed / 500
			#print(camera_target_beyond)
			
			camera_position = lerp(global_position, player.global_position, weight)
			#camera_position = lerp(global_position, player.global_position + camera_target_beyond, weight)
		else:
			camera_position = player.global_position
			
		#print("Weight: ", weight, "Camera Position: ", camera_position, "Camera Pixel Floor: ", camera_position.floor())
		
		global_position = camera_position
