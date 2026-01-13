extends Node2D

#@export var player_visibility : VisibleOnScreenNotifier2D
@onready var dragon_node = get_parent()
@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node = get_parent().get_parent().get_node("Camera2D")
@export var look_marker : Sprite2D
var lag_threshold = Vector2()
var duration_step = 2.0
var new_position = Vector2(0,0)
var is_looking = false

enum {GROUND, NEAR, FAR, MAX}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var weight = 0.1
# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		weight = 0.01
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
		var distance_lag = Vector2(dragon_node.current_speed / 1.01, dragon_node.current_speed / 1.1)
		
		if camera_node.current_zoom_level == GROUND:
			distance_lag *= 0.9
		elif camera_node.current_zoom_level == NEAR:
			distance_lag *= 0.9
		elif camera_node.current_zoom_level == FAR:
			distance_lag *= 1.01
			#lag_threshold = viewport_dimensions * 2
		else:
			distance_lag *= 1.4
			#lag_threshold = viewport_dimensions * 3
		#print(distance_lag)
		#print(lag_threshold)
		#print(viewport_dimensions)
		
		## Updating the threshold based on the size of the screen
		#lag_threshold = viewport_dimensions
		#if distance_lag.x > lag_threshold.x:
			#distance_lag.x = lag_threshold.x
		#if distance_lag.y > lag_threshold.y:
			#distance_lag.y = lag_threshold.y
		new_position = dragon_node.flight_direction * distance_lag
		weight = dragon_node.current_speed * 0.00006
	else:
		new_position = Vector2(0,0)
		weight = 0.05
	
	position = lerp(position, new_position, weight)
