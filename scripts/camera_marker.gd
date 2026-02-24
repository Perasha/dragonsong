extends Node2D

#@export var player_visibility : VisibleOnScreenNotifier2D
@onready var dragon_node = get_parent()
@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node = get_parent().get_parent().get_node("Camera2D")
@onready var raycast_anchor = get_parent().get_node("RayCastAnchor")
@export var look_marker : Sprite2D
var screen_threshold = Vector2()
var duration_step = 2.0
var new_position = Vector2(0,0)
var is_looking = false
var current_anchor = Vector2(0,0)

## Ground, Near, Far, Max
var distance_limit = [Vector2(500,300),Vector2(1000,500),Vector2(2000,1500),Vector2(3000,2000)]
#var distance_limit = [Vector2(500,300),Vector2(500,300),Vector2(500,300),Vector2(500,300)]

## By adjusting this value, we essentially make sure that our character doesn't ever leave the frame.
@export var zoom_dist_constraint = Vector2(150000,5000)
enum {GROUND, NEAR, FAR, MAX}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var weight = 0.1


## Screen Position Calibration
#var ci: CanvasItem = self
#@onready var root: Window = ci.get_tree().root

#var ci_screen_pos: Vector2 

func _process(delta: float) -> void:
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
	
	if look_marker.visible and is_looking == false:
		look_marker.hide()
	elif not look_marker.visible and is_looking == true:
		look_marker.show()
	
	var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
	
	if is_looking:
		#weight = 0.01
		#print("looking!")
		#print(position)
		#print(get_viewport().get_mouse_position())
		#var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
		new_position = (get_viewport().get_mouse_position() - (viewport_dimensions / 2))
		if camera_node.current_zoom_level == GROUND:
			new_position *= 1.5
		elif camera_node.current_zoom_level == NEAR:
			new_position *= 2
		elif camera_node.current_zoom_level == FAR:
			new_position *= 3
		else:
			new_position *= 5
		#print(new_position)
		#weight = 0.05
	
	elif dragon_node.is_flying:
		var distance_lag = Vector2(dragon_node.current_speed / 1.05, dragon_node.current_speed / 1.1)
		var distance_threshold = camera_node.zoom * zoom_dist_constraint
		## ZOOM DISTANCE LIMITS:
		## MAX: 3000
		## FAR: 2500
		## NEAR: 1300X, 800Y
		
		print("Camera Zoom: ", camera_node.zoom)
		if camera_node.current_zoom_level == GROUND:
			distance_lag *= 0.9
			#distance_threshold = distance_limit[GROUND]
		elif camera_node.current_zoom_level == NEAR:
			distance_lag *= 0.9
			#distance_threshold = distance_limit[NEAR]
		elif camera_node.current_zoom_level == FAR:
			distance_lag *= 1.01
			#distance_threshold = distance_limit[FAR]
			#screen_threshold = viewport_dimensions * 2
		else:
			distance_lag *= 1.4
			#distance_threshold = distance_limit[MAX]
		
		new_position = dragon_node.flight_direction * distance_lag		
		weight = dragon_node.current_speed * 0.00006
		
		## Auto-look
		## If our Zoom level is high enough AND we're out of bounds of the new threshold we set, 
		## Find an Anchor within a Distance
		## Move our marker to that Anchor
		
		#print("Distance from Marker to Dragon: ", dragon_node.position.distance_to(camera_node.position))
		
		if camera_node.current_zoom_level == MAX and dragon_node.position.distance_to(current_anchor) > distance_threshold.x:
			var anchor = Vector2(0,0)
			#raycast_anchor.position = dragon_node.position
			raycast_anchor.force_raycast_update()
			anchor = raycast_anchor.get_collision_point()
			#print(anchor)
			#print("Local: ", to_local(anchor))
			#if anchor != Vector2(0,0):
				#new_position = to_local(anchor)
			new_position.y += to_local(anchor).y
				#current_anchor = new_position
		
		new_position = new_position.clamp(-distance_threshold,distance_threshold)
		
	else:
		new_position = Vector2(0,0)
		weight = 0.05
	
	position = lerp(position, new_position, weight)
